"""Turn a Firedrake local kernel into an OP2-MLIR canonical kernel artifact.

Pipeline
--------
1. ``capture_local_kernels``: while Firedrake compiles a form with the GEM/MLIR
   backend, grab each *local kernel* (the per-cell maths TSFC produces, as GEM)
   before pyop3 inlines it into its own mesh loop.
2. ``build_local_func``: run Firedrake's ``MLIRBuilder`` on just that kernel.
   The result works on small packed per-cell arrays, e.g. ``A[6]``, ``coords[6]``.
3. ``build_canonical_func``: wrap it in the function OP2 calls once per element.
   OP2 passes one strided memref per ``op_arg`` (e.g. one per vertex), so the
   wrapper gathers those into the packed arrays, calls the local kernel, and
   writes / adds the results back. The local kernel body is inlined into the wrapper.
4. ``write_artifact``: emit ``<name>.mlir``, ``<name>.mlirbc`` and the
   ``<name>.json`` manifest that OP2's artifact loader reads.

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
from dataclasses import dataclass
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


@contextlib.contextmanager
def capture_local_kernels():
    """Record every local kernel pyop3's GEM compiler inlines while active.

    Usage::

        with capture_local_kernels() as kernels:
            assemble(form, pyop3_compiler_parameters={"backend": "gem"}, ...)
        kernel = kernels[0]
    """
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


# {{{ 2. local kernel -> MLIR

def _impero_tree(kernel: LocalKernel):
    """GEM assignments -> Impero tree, mirroring GemExecutable._callable."""
    # Same hack as pyop3: the kernel writes/increments only its first argument.
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


# {{{ 3. canonical wrapper OP2 calls

@dataclass(frozen=True)
class Op2Arg:
    """One OP2 ``op_arg``: it covers ``kernel_arg[offset : offset + size]``."""
    kernel_arg: str
    offset: int
    size: int


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

    # Gather: OP2 views -> packed arrays, for anything the kernel reads.
    for a, view in zip(op2_args, block.args):
        if intent[a.kernel_arg] == Intent.READ:
            for j in range(a.size):
                v = b.insert(memref.LoadOp.get(view, [index(j)])).res
                b.insert(memref.StoreOp.get(v, local_bufs[a.kernel_arg], [index(a.offset + j)]))

    # Call the Firedrake kernel (its args are memref<?xT>).
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

    # Scatter: packed arrays -> OP2 views. INC adds into the view (OP2 handles races).
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


# {{{ 4. write files

def _mlir_opt() -> str:
    path = shutil.which("mlir-opt")
    if path is None:
        prefix = subprocess.check_output(["brew", "--prefix", "llvm"], text=True).strip()
        path = f"{prefix}/bin/mlir-opt"
    return path


def write_artifact(kernel: LocalKernel, op2_args: list[Op2Arg], name: str,
                   header: Path, outdir: Path) -> Path:
    """Build the module, check it with mlir-opt, and write the artifact files.

    :arg header: the C++ stand-in that op_par_loop names; its SHA-256 goes into
        the manifest so OP2 knows the artifact belongs to it.
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

# }}}
