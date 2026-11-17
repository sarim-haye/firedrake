// Hand-written "Firedrake-style" kernel in OP2's canonical artifact form.
// One call = one mesh element: OP2 passes a view starting at that element,
// so the kernel always reads/writes index 0 and has no loop of its own.
// Argument order must match the op_arg_dat order in op_par_loop (out, in).
module {
  func.func private @fd_scale(%out: memref<?xf64, strided<[?], offset: ?>>,
                              %in:  memref<?xf64, strided<[?], offset: ?>>)
      attributes {op2.kernel_artifact_canonical_abi, op2.kernel_ir} {
    %c0  = arith.constant 0 : index
    %two = arith.constant 2.0 : f64
    %x   = memref.load %in[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %y   = arith.mulf %x, %two : f64
    memref.store %y, %out[%c0] : memref<?xf64, strided<[?], offset: ?>>
    return
  }
}
