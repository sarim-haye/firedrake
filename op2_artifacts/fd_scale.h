// C++ stand-in for the Firedrake kernel `fd_scale`.
//
// OP2 needs a real C++ function to name in op_par_loop, and the artifact
// manifest records this file's SHA-256. If the Firedrake artifact is accepted,
// this body is never run. The -999 is deliberate: seeing it in the output
// means OP2 rejected the artifact and fell back to this C++ code.
inline void fd_scale(double *out, const double *in) { out[0] = -999.0; }
