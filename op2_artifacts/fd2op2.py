"""Turn a Firedrake local kernel into an OP2-MLIR canonical kernel artifact.

Pipeline
--------
1. ``capture_local_kernels``: while Firedrake compiles a form with the GEM/MLIR
   backend, grab each *local kernel* (the per-cell maths TSFC produces, as GEM)
   before pyop3 inlines it into its own mesh loop.
2. ``bind_one_form``: work out the OP2 loop that runs the kernel. TSFC's kernel
   info says what each kernel argument is (the output, the mesh coordinates, a
   coefficient or a constant). Each argument on a function space becomes one
   OP2 dat with one ``op_arg`` per node of the cell, through that space's cell
   map. A constant becomes one ``op_arg_gbl``.
3. ``build_local_func``: run Firedrake's ``MLIRBuilder`` on just the kernel.
   The result works on small packed per-cell arrays, e.g. ``A[6]``, ``coords[6]``.
4. ``build_canonical_func``: wrap it in the function OP2 calls once per element.
   OP2 passes one strided memref per ``op_arg``, so the wrapper gathers those
   into the packed arrays, runs the inlined kernel body, and writes or adds
   the results back.
5. ``write_artifact`` emits ``<name>.mlir``, ``<name>.mlirbc`` and the
   ``<name>.json`` manifest that OP2's artifact loader reads.
   ``write_op2_files`` emits ``<name>.h``, the C++ stand-in that
   ``op_par_loop`` names, and ``<name>_op2.h``, the mesh data, the
   ``op_par_loop`` call and Firedrake's reference result for OP2's test.

OP2 does the mesh loop, the maps and the race-free INC handling itself; the
artifact only contains per-element work.
"""

from __future__ import annotations

import contextlib
import hashlib
import json
import math
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from types import SimpleNamespace

import numpy as np

from gem import impero, impero_utils
from xdsl.dialects import arith, func, memref
from xdsl.dialects.builtin import (
    DYNAMIC_INDEX,
    FloatAttr,
    IndexType,
    MemRefType,
    ModuleOp,
    StridedLayoutAttr,
    StringAttr,
    UnitAttr,
)
from xdsl.builder import Builder, InsertPoint
from xdsl.ir import Block, Region

import pyop3.cache
import pyop3.insn
from pyop3.compile import gem as pyop3_gem
from pyop3.compile.mlir import MLIRBuilder, get_mlir_type
from pyop3.constants import Intent


# {{{ 1. capture

@dataclass
class LocalKernel:
    """A Firedrake local kernel, as GEM, plus what its arguments look like."""
    insns: list            # [(lhs, rhs)] GEM assignments
    arg_names: tuple[str, ...]
    shapes: tuple[tuple[int, ...], ...]
    dtypes: tuple[np.dtype, ...]
    intents: tuple[Intent, ...]

    def size(self, name: str) -> int:
        return math.prod(self.shapes[self.arg_names.index(name)])

    def intent(self, name: str) -> Intent:
        return self.intents[self.arg_names.index(name)]


@contextlib.contextmanager
def capture_local_kernels(comm=None):
    """Record every local kernel that pyop3's GEM compiler inlines while active.

    pyop3 keeps compiled loops in a memory cache, and a cache hit skips the
    compiler, so nothing would be recorded. If ``comm`` is given, the memory
    cache on that communicator is cleared first, so that the loop is compiled.

    Usage::

        with capture_local_kernels(mesh.comm) as kernels:
            assemble(form, pyop3_compiler_parameters={"backend": "gem"}, ...)
        kernel = kernels[0]
    """
    if comm is not None:
        pyop3.cache.clear_memory_cache(comm)
    dispatcher = pyop3_gem.GemCompiler.__dict__["process"].dispatcher
    original = dispatcher.registry[pyop3.insn.StandaloneCalledFunction]
    captured: list[LocalKernel] = []

    def spy(self, call):
        insns, names = call.function.code
        captured.append(LocalKernel(
            insns=list(insns),
            arg_names=tuple(names),
            shapes=tuple(tuple(int(n) for n in a.buffer.shape) for a in call.arguments),
            dtypes=tuple(np.dtype(a.buffer.dtype) for a in call.arguments),
            intents=tuple(call.function.intents),
        ))
        return original(self, call)

    dispatcher.register(pyop3.insn.StandaloneCalledFunction, spy)
    try:
        yield captured
    finally:
        dispatcher.register(pyop3.insn.StandaloneCalledFunction, original)

# }}}


# {{{ 2. OP2 loop binding

OP2_ACCESS = {Intent.READ: "OP_READ", Intent.WRITE: "OP_WRITE", Intent.INC: "OP_INC"}


@dataclass(frozen=True)
class Op2Arg:
    """One OP2 ``op_arg``. It covers ``kernel_arg[offset : offset + size]``.

    ``dat`` is an index into ``Op2Loop.dats``, and ``map_index`` selects the
    node of the cell map. If ``dat`` is ``None``, the argument is an
    ``op_arg_gbl`` and its values are in ``Op2Loop.globals[kernel_arg]``.
    """
    kernel_arg: str
    offset: int
    size: int
    dat: int | None = None
    map_index: int = -1


@dataclass
class Op2Dat:
    """An OP2 set, dat and cell map that hold one Firedrake function space."""
    name: str
    cell_map: np.ndarray   # (ncells, nodes per cell), Firedrake's local node order
    dim: int               # values per node (the block size)
    values: np.ndarray     # initial values, (nnodes * dim,)

    @property
    def nnodes(self) -> int:
        return self.values.size // self.dim


@dataclass
class Op2Loop:
    """Everything that the OP2 side needs to run one Firedrake local kernel."""
    ncells: int
    dats: list[Op2Dat] = field(default_factory=list)
    args: list[Op2Arg] = field(default_factory=list)
    globals: dict[str, np.ndarray] = field(default_factory=dict)
    output: int = 0        # index of the dat that the kernel assembles into

    def add_dat(self, kernel: LocalKernel, kernel_arg: str, name: str,
                function_space, values: np.ndarray) -> None:
        cell_map = np.asarray(function_space.cell_node_list)
        dim = function_space.block_size
        arity = cell_map.shape[1]
        if kernel.size(kernel_arg) != arity * dim:
            raise ValueError(
                f"{kernel_arg!r} has {kernel.size(kernel_arg)} entries, but its space "
                f"has {arity} nodes per cell with {dim} values each"
            )
        self.dats.append(Op2Dat(name, cell_map, dim, np.asarray(values, dtype=float).ravel()))
        index = len(self.dats) - 1
        # The packed kernel array is node-major: node i owns entries [i*dim, (i+1)*dim).
        self.args += [Op2Arg(kernel_arg, i * dim, dim, index, i) for i in range(arity)]


def bind_one_form(form, kernel: LocalKernel) -> Op2Loop:
    """Derive the OP2 loop that runs ``kernel``, the local kernel of the one-form ``form``.

    The kernel arguments are matched, in order, with the kernel argument
    descriptions in TSFC's kernel info. Coefficients and constants are found
    with the same helpers that Firedrake's own assembler uses.
    """
    from firedrake import Function
    from firedrake.assemble import _FormHandler
    from firedrake.tsfc_interface import compile_form
    from tsfc import kernel_args

    if len(form.arguments()) != 1:
        raise NotImplementedError("only one-forms (assembled vectors) are supported")
    split_kernels = compile_form(form, "fd2op2", parameters={"backend": "gem"})
    if len(split_kernels) != 1 or split_kernels[0].kinfo.integral_type != "cell":
        raise NotImplementedError("only forms with a single cell integral are supported")
    kinfo = split_kernels[0].kinfo
    if len(kinfo.arguments) != len(kernel.arg_names):
        raise ValueError(f"TSFC describes {len(kinfo.arguments)} kernel arguments, "
                         f"but the captured kernel has {len(kernel.arg_names)}")

    mesh = form.ufl_domain()
    coefficients = iter(_FormHandler.iter_active_coefficients(form, kinfo))
    constants = iter(_FormHandler.iter_constants(form, kinfo))
    loop = Op2Loop(ncells=mesh.coordinates.function_space().cell_node_list.shape[0])

    for name, description in zip(kernel.arg_names, kinfo.arguments):
        match description:
            case kernel_args.OutputKernelArg():
                space = form.arguments()[0].function_space()
                loop.output = len(loop.dats)
                loop.add_dat(kernel, name, "result", space, Function(space).dat.data_ro)
            case kernel_args.CoordinatesKernelArg():
                coords = mesh.coordinates
                loop.add_dat(kernel, name, "coords", coords.function_space(), coords.dat.data_ro)
            case kernel_args.CoefficientKernelArg():
                f = next(coefficients)
                loop.add_dat(kernel, name, f"coeff_{name}", f.function_space(), f.dat.data_ro)
            case kernel_args.ConstantKernelArg():
                values = np.atleast_1d(np.asarray(next(constants).dat.data_ro, dtype=float)).ravel()
                if values.size != kernel.size(name):
                    raise ValueError(f"constant {name!r} has {values.size} values, "
                                     f"the kernel expects {kernel.size(name)}")
                loop.globals[name] = values
                loop.args.append(Op2Arg(name, 0, values.size))
            case _:
                raise NotImplementedError(
                    f"kernel argument {name!r} ({type(description).__name__}) is not supported")
    return loop

# }}}


# {{{ 3. local kernel -> MLIR

def _impero_tree(kernel: LocalKernel):
    """Convert the GEM assignments to an Impero tree, as GemExecutable._callable does."""
    # Same assumption as pyop3: the kernel writes or increments only its first argument.
    mode = {Intent.WRITE: "write", Intent.INC: "inc"}[kernel.intents[0]]
    assignments = []
    for lhs, rhs in kernel.insns:
        rhs, = impero_utils.preprocess_gem([rhs])
        lhs, = impero_utils.preprocess_gem([lhs])
        assignments.append(impero.Assignment(assignee=lhs, expression=rhs, mode=mode))
    return impero_utils.compile_gem_new(assignments, ()).tree


def build_local_func(kernel: LocalKernel, name: str):
    """Return ``(global_ops, func_op)`` for the local kernel on packed arrays."""
    # MLIRBuilder only reads `.buffer.dtype` from each argument and drops NullBuffers.
    arguments = {
        n: SimpleNamespace(buffer=SimpleNamespace(dtype=d))
        for n, d in zip(kernel.arg_names, kernel.dtypes)
    }
    builder = MLIRBuilder(_impero_tree(kernel), arguments, name=name)
    builder.process(builder._root)
    builder.insert(func.ReturnOp())

    f = builder._func_op
    del f.attributes["llvm.emit_c_interface"]
    f.sym_visibility = StringAttr("private")
    return builder.global_ops, f

# }}}


# {{{ 4. canonical wrapper that OP2 calls

def canonical_memref(elem):
    """OP2's canonical per-element view: rank 1, dynamic size, stride and offset."""
    return MemRefType(elem, [DYNAMIC_INDEX], StridedLayoutAttr([None], None))


def build_canonical_func(kernel: LocalKernel, local: func.FuncOp,
                         op2_args: list[Op2Arg], name: str) -> func.FuncOp:
    # Every element of every kernel argument must come from exactly one op_arg.
    for arg_name in kernel.arg_names:
        covered = sorted(
            i for a in op2_args if a.kernel_arg == arg_name
            for i in range(a.offset, a.offset + a.size)
        )
        if covered != list(range(kernel.size(arg_name))):
            raise ValueError(f"op_args do not cover {arg_name!r} exactly once: {covered}")

    elem = {n: get_mlir_type(d) for n, d in zip(kernel.arg_names, kernel.dtypes)}
    intent = dict(zip(kernel.arg_names, kernel.intents))
    arg_types = [canonical_memref(elem[a.kernel_arg]) for a in op2_args]

    block = Block(arg_types=arg_types)
    b = Builder(InsertPoint.at_end(block))
    idx = {}

    def index(i):
        if i not in idx:
            idx[i] = b.insert(arith.ConstantOp.from_int_and_width(i, IndexType())).result
        return idx[i]

    # One static local array per kernel argument (the "packed" layout).
    local_bufs = {}
    for n in kernel.arg_names:
        size = kernel.size(n)
        buf = b.insert(memref.AllocaOp.get(elem[n], shape=[size])).memref
        local_bufs[n] = buf
        if intent[n] == Intent.INC:
            zero = b.insert(arith.ConstantOp(FloatAttr(0.0, elem[n]))).result
            for i in range(size):
                b.insert(memref.StoreOp.get(zero, buf, [index(i)]))

    # Gather: copy the OP2 views into the packed arrays, for anything the kernel reads.
    for a, view in zip(op2_args, block.args):
        if intent[a.kernel_arg] == Intent.READ:
            for j in range(a.size):
                v = b.insert(memref.LoadOp.get(view, [index(j)])).res
                b.insert(memref.StoreOp.get(v, local_bufs[a.kernel_arg], [index(a.offset + j)]))

    # Inline the Firedrake kernel body here, with its memref<?xT> arguments
    # replaced by casts of the packed arrays. The artifact then has no func.call,
    # because OP2 declares every unresolved callee as an external maths function.
    value_map = {
        local_arg: b.insert(
            memref.CastOp.get(local_bufs[n], MemRefType(elem[n], [DYNAMIC_INDEX]))
        ).dest
        for n, local_arg in zip(kernel.arg_names, local.body.block.args)
    }
    for op in local.body.block.ops:
        if isinstance(op, func.ReturnOp):
            break
        b.insert(op.clone(value_mapper=value_map))

    # Scatter: copy the packed arrays to the OP2 views. INC adds into the view,
    # and OP2 prevents two cells from adding into the same node at the same time.
    for a, view in zip(op2_args, block.args):
        mode = intent[a.kernel_arg]
        if mode == Intent.READ:
            continue
        for j in range(a.size):
            v = b.insert(memref.LoadOp.get(local_bufs[a.kernel_arg], [index(a.offset + j)])).res
            if mode == Intent.INC:
                old = b.insert(memref.LoadOp.get(view, [index(j)])).res
                v = b.insert(arith.AddfOp(old, v)).result
            b.insert(memref.StoreOp.get(v, view, [index(j)]))

    b.insert(func.ReturnOp())

    f = func.FuncOp(name, (arg_types, []), Region(block), visibility="private")
    f.attributes["op2.kernel_artifact_canonical_abi"] = UnitAttr()
    f.attributes["op2.kernel_ir"] = UnitAttr()
    return f

# }}}


# {{{ 5. write files

def _mlir_opt() -> str:
    path = shutil.which("mlir-opt")
    if path is None:
        prefix = subprocess.check_output(["brew", "--prefix", "llvm"], text=True).strip()
        path = f"{prefix}/bin/mlir-opt"
    return path


def write_artifact(kernel: LocalKernel, op2_args: list[Op2Arg], name: str,
                   header: Path, outdir: Path) -> Path:
    """Build the module, check it with mlir-opt, and write the artifact files.

    :arg header: the C++ stand-in that op_par_loop names. Its SHA-256 goes into
        the manifest so that OP2 knows the artifact belongs to it.
    """
    global_ops, local = build_local_func(kernel, f"{name}_local")
    canonical = build_canonical_func(kernel, local, op2_args, name)
    module = ModuleOp([*global_ops, canonical])
    module.verify()

    outdir.mkdir(parents=True, exist_ok=True)
    mlir_path = outdir / f"{name}.mlir"
    mlir_path.write_text(str(module) + "\n")

    # Tidy up with mlir-opt. This also checks that upstream MLIR parses the module.
    opt = _mlir_opt()
    subprocess.run([opt, str(mlir_path), "--canonicalize", "-o", str(mlir_path)], check=True)
    subprocess.run([opt, str(mlir_path), "--emit-bytecode", "-o", str(outdir / f"{name}.mlirbc")], check=True)

    header = header.resolve()
    manifest = {
        "format_version": 1,
        "language": "cpp",
        "kernel": name,
        "source": str(header),
        "source_digest": hashlib.sha256(header.read_bytes()).hexdigest(),
        "constants": [],
    }
    (outdir / f"{name}.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return mlir_path


def _c_array(ctype: str, name: str, values) -> str:
    values = np.asarray(values).ravel()
    fmt = repr if ctype == "double" else str
    items = [fmt(float(x)) if ctype == "double" else fmt(int(x)) for x in values]
    rows = ",\n  ".join(", ".join(items[i:i + 8]) for i in range(0, len(items), 8))
    return f"static {ctype} {name}[] = {{\n  {rows}\n}};\n"


def _stand_in(name: str, kernel: LocalKernel, loop: Op2Loop) -> str:
    params = []
    for i, a in enumerate(loop.args):
        const = "const " if kernel.intent(a.kernel_arg) == Intent.READ else ""
        params.append(f"{const}double *arg{i}")
    first = "arg0[0] += -999.0;" if kernel.intents[0] == Intent.INC else "arg0[0] = -999.0;"
    return (
        f"// Generated by fd2op2.py: C++ stand-in for the Firedrake kernel `{name}`.\n"
        "//\n"
        "// OP2 needs a real C++ function to name in op_par_loop, and the artifact\n"
        "// manifest records this file's SHA-256. If OP2 accepts the Firedrake\n"
        "// artifact, this body never runs. The -999 is deliberate: seeing it in the\n"
        "// output means that OP2 fell back to this C++ code.\n"
        "#pragma once\n"
        f"inline void {name}({', '.join(params)}) {{ {first} }}\n"
    )


def write_op2_files(name: str, kernel: LocalKernel, loop: Op2Loop,
                    reference: np.ndarray, outdir: Path) -> Path:
    """Write ``<name>.h`` (the stand-in) and ``<name>_op2.h`` (the OP2 test case).

    ``<name>_op2.h`` defines a ``fd_kernel`` namespace that OP2's generic
    ``fd_artifact_test.cpp`` uses: the mesh data of every dat, a ``run``
    function with the ``op_par_loop`` call, and Firedrake's reference result.
    """
    header = outdir / f"{name}.h"
    header.write_text(_stand_in(name, kernel, loop))

    out = [
        f"// Generated by fd2op2.py: OP2 test case for the Firedrake kernel `{name}`.\n",
        "#pragma once\n",
        '#include "fd_artifact_harness.h"\n',
        f'#include "{name}.h"\n\n',
        "namespace fd_kernel {\n",
        f'static const char *name = "{name}";\n',
        f"static const int ncells = {loop.ncells};\n",
        f"static const int output = {loop.output};\n",
    ]
    for i, d in enumerate(loop.dats):
        out.append(_c_array("int", f"dat{i}_map", d.cell_map))
        out.append(_c_array("double", f"dat{i}_values", d.values))
    out.append("static const FdDatData dats[] = {\n")
    for i, d in enumerate(loop.dats):
        out.append(f'  {{"{d.name}", {d.nnodes}, {d.dim}, {d.cell_map.shape[1]}, '
                   f"dat{i}_map, dat{i}_values}},\n")
    out.append("};\n")
    out.append(f"static const int ndats = {len(loop.dats)};\n")
    for gname, values in loop.globals.items():
        out.append(_c_array("double", f"global_{gname}", values))
    out.append(_c_array("double", "reference", reference))

    calls = []
    for a in loop.args:
        access = OP2_ACCESS[kernel.intent(a.kernel_arg)]
        if a.dat is None:
            calls.append(f'op_arg_gbl(global_{a.kernel_arg}, {a.size}, "double", {access})')
        else:
            calls.append(f'op_arg_dat(p.dats[{a.dat}], {a.map_index}, p.maps[{a.dat}], '
                         f'{a.size}, "double", {access})')
    out.append("\n// Argument order matches the artifact's function arguments.\n")
    out.append("inline void run(FdProblem &p) {\n")
    out.append(f'  op_par_loop({name}, "{name}", p.cells,\n              ')
    out.append(",\n              ".join(calls))
    out.append(");\n}\n} // namespace fd_kernel\n")

    path = outdir / f"{name}_op2.h"
    path.write_text("".join(out))
    return header

# }}}
