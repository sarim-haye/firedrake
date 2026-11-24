// C++ stand-in for the Firedrake-generated kernel `fd_xy` (x * y * v * dx, P2).
//
// OP2 needs a real C++ function to name in op_par_loop, and the artifact
// manifest records this file's SHA-256. If the Firedrake artifact is accepted,
// this body is never run. Adding -999 is deliberate: seeing it in the output
// means OP2 rejected the artifact and fell back to this C++ code.
//
// Argument order = artifact argument order: 6 P2 nodes (INC), 3 vertex
// coordinates (READ).
inline void fd_xy(double *A0, double *A1, double *A2, double *A3, double *A4,
                  double *A5, const double *X0, const double *X1,
                  const double *X2) {
  A0[0] += -999.0;
}
