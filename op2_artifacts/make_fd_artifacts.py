"""Generate OP2 artifacts and OP2 test cases from real Firedrake forms.

Each case is a cell-integral one-form on ``UnitSquareMesh(n, n)``. For each case
``<name>`` this assembles the form with Firedrake's GEM/MLIR backend, captures
the local kernel, derives the OP2 loop that runs it (see ``fd2op2.bind_one_form``),
and writes:

- ``<name>.mlir``, ``<name>.mlirbc`` and ``<name>.json``: the OP2 kernel artifact.
- ``<name>.h``: the C++ stand-in that ``op_par_loop`` names.
- ``<name>_op2.h``: the mesh data, the ``op_par_loop`` call and Firedrake's
  assembled vector. OP2's ``fd_artifact_test.cpp`` runs it and compares every
  node with Firedrake's result.

To add a case, add an entry to ``CASES``. OP2's CMake registers a test for every
``*_op2.h`` file that it finds.

Run with the MLIR branch environment::

    PYTHONPATH=firedrake-mlir:fiat-mlir python firedrake-mlir/op2_artifacts/make_fd_artifacts.py [case ...]
"""

import sys
from pathlib import Path

import numpy as np
from firedrake import (
    Constant, Function, FunctionSpace, SpatialCoordinate, TestFunction, UnitSquareMesh,
    assemble, dx,
)

from fd2op2 import bind_one_form, capture_local_kernels, write_artifact, write_op2_files

HERE = Path(__file__).resolve().parent


def mass_form(mesh):
    """c * v * dx on P2. Vertex nodes get 0 and edge nodes get c * area / 3."""
    v = TestFunction(FunctionSpace(mesh, "P", 2))
    return Constant(10.0) * v * dx


def xy_form(mesh, degree=2):
    """x * y * v * dx. Almost every node gets a different value, so a wrong ordering shows."""
    x, y = SpatialCoordinate(mesh)
    v = TestFunction(FunctionSpace(mesh, "P", degree))
    return x * y * v * dx


def coeff_form(mesh):
    """c * f * v * dx with f a P1 coefficient and v in P2: a coefficient on a second space."""
    f = Function(FunctionSpace(mesh, "P", 1))
    f.dat.data[:] = np.random.default_rng(seed=0).uniform(1.0, 2.0, f.dat.data.shape)
    v = TestFunction(FunctionSpace(mesh, "P", 2))
    return Constant(3.0) * f * v * dx


# name -> (form builder, cells per side of the unit square mesh)
CASES = {
    "fd_mass": (mass_form, 3),
    "fd_xy": (xy_form, 3),
    "fd_coeff": (coeff_form, 3),
    "fd_p3": (lambda mesh: xy_form(mesh, degree=3), 3),
    "fd_xy_big": (xy_form, 64),
}


def build_case(name, make_form, n):
    form = make_form(UnitSquareMesh(n, n))
    with capture_local_kernels(form.ufl_domain().comm) as kernels:
        result = assemble(
            form,
            pyop3_compiler_parameters={"backend": "gem"},
            form_compiler_parameters={"backend": "gem"},
        )
    if len(kernels) != 1:
        raise RuntimeError(f"{name}: expected one local kernel, got {len(kernels)}")
    kernel = kernels[0]

    loop = bind_one_form(form, kernel)
    header = write_op2_files(name, kernel, loop, result.dat.data_ro, HERE)
    write_artifact(kernel, loop.args, name, header, HERE)

    dats = ", ".join(f"{d.name}({d.cell_map.shape[1]}x{d.dim})" for d in loop.dats)
    print(f"{name}: {loop.ncells} cells, {len(loop.args)} op_args [{dats}"
          f"{', globals ' + ', '.join(loop.globals) if loop.globals else ''}], "
          f"reference sum = {result.dat.data_ro.sum():.15g}")


if __name__ == "__main__":
    names = sys.argv[1:] or list(CASES)
    for name in names:
        make_form, n = CASES[name]
        build_case(name, make_form, n)
