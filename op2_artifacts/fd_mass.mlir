module {
  memref.global "private" constant @literal_0 : memref<18xf64> = dense<[0.22222222222222229, -0.11111111111111116, -0.11111111111111116, 0.44444444444444448, 0.11111111111111113, 0.44444444444444464, 0.44444444444444442, 0.44444444444444464, 0.11111111111111123, -0.11111111111111108, -0.11111111111111102, 0.22222222222222213, 0.11111111111111106, 0.44444444444444425, 0.44444444444444425, -0.11111111111111105, 0.22222222222222213, -0.11111111111111106]>
  memref.global "private" constant @literal_1 : memref<3xf64> = dense<0.16666666666666666>
  func.func private @fd_mass(%arg0: memref<?xf64, strided<[?], offset: ?>>, %arg1: memref<?xf64, strided<[?], offset: ?>>, %arg2: memref<?xf64, strided<[?], offset: ?>>, %arg3: memref<?xf64, strided<[?], offset: ?>>, %arg4: memref<?xf64, strided<[?], offset: ?>>, %arg5: memref<?xf64, strided<[?], offset: ?>>, %arg6: memref<?xf64, strided<[?], offset: ?>>, %arg7: memref<?xf64, strided<[?], offset: ?>>, %arg8: memref<?xf64, strided<[?], offset: ?>>, %arg9: memref<?xf64, strided<[?], offset: ?>>) attributes {op2.kernel_artifact_canonical_abi, op2.kernel_ir} {
    %cst = arith.constant 0.16666666666666666 : f64
    %c6 = arith.constant 6 : index
    %cst_0 = arith.constant -1.000000e+00 : f64
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %cst_1 = arith.constant 0.000000e+00 : f64
    %alloca = memref.alloca() : memref<6xf64>
    memref.store %cst_1, %alloca[%c0] : memref<6xf64>
    memref.store %cst_1, %alloca[%c1] : memref<6xf64>
    memref.store %cst_1, %alloca[%c2] : memref<6xf64>
    memref.store %cst_1, %alloca[%c3] : memref<6xf64>
    memref.store %cst_1, %alloca[%c4] : memref<6xf64>
    memref.store %cst_1, %alloca[%c5] : memref<6xf64>
    %alloca_2 = memref.alloca() : memref<6xf64>
    %alloca_3 = memref.alloca() : memref<1xf64>
    %0 = memref.load %arg6[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %0, %alloca_2[%c0] : memref<6xf64>
    %1 = memref.load %arg6[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %1, %alloca_2[%c1] : memref<6xf64>
    %2 = memref.load %arg7[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %2, %alloca_2[%c2] : memref<6xf64>
    %3 = memref.load %arg7[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %3, %alloca_2[%c3] : memref<6xf64>
    %4 = memref.load %arg8[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %4, %alloca_2[%c4] : memref<6xf64>
    %5 = memref.load %arg8[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %5, %alloca_2[%c5] : memref<6xf64>
    %6 = memref.load %arg9[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %6, %alloca_3[%c0] : memref<1xf64>
    %7 = memref.get_global @literal_0 : memref<18xf64>
    scf.for %arg10 = %c0 to %c6 step %c1 {
      %26 = scf.for %arg11 = %c0 to %c3 step %c1 iter_args(%arg12 = %cst_1) -> (f64) {
        %29 = arith.muli %arg10, %c3 : index
        %30 = arith.addi %29, %arg11 : index
        %31 = memref.load %7[%30] : memref<18xf64>
        %32 = memref.load %alloca_2[%c0] : memref<6xf64>
        %33 = arith.mulf %32, %cst_0 : f64
        %34 = memref.load %alloca_2[%c2] : memref<6xf64>
        %35 = arith.addf %33, %34 : f64
        %36 = memref.load %alloca_2[%c1] : memref<6xf64>
        %37 = arith.mulf %36, %cst_0 : f64
        %38 = memref.load %alloca_2[%c5] : memref<6xf64>
        %39 = arith.addf %37, %38 : f64
        %40 = arith.mulf %35, %39 : f64
        %41 = memref.load %alloca_2[%c0] : memref<6xf64>
        %42 = arith.mulf %41, %cst_0 : f64
        %43 = memref.load %alloca_2[%c4] : memref<6xf64>
        %44 = arith.addf %42, %43 : f64
        %45 = memref.load %alloca_2[%c1] : memref<6xf64>
        %46 = arith.mulf %45, %cst_0 : f64
        %47 = memref.load %alloca_2[%c3] : memref<6xf64>
        %48 = arith.addf %46, %47 : f64
        %49 = arith.mulf %44, %48 : f64
        %50 = arith.mulf %49, %cst_0 : f64
        %51 = arith.addf %40, %50 : f64
        %52 = math.absf %51 : f64
        %53 = arith.mulf %52, %cst : f64
        %54 = memref.load %alloca_3[%c0] : memref<1xf64>
        %55 = arith.mulf %53, %54 : f64
        %56 = arith.mulf %31, %55 : f64
        %57 = arith.addf %arg12, %56 : f64
        scf.yield %57 : f64
      }
      %27 = memref.load %alloca[%arg10] : memref<6xf64>
      %28 = arith.addf %27, %26 : f64
      memref.store %28, %alloca[%arg10] : memref<6xf64>
    }
    %8 = memref.load %alloca[%c0] : memref<6xf64>
    %9 = memref.load %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %10 = arith.addf %9, %8 : f64
    memref.store %10, %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %11 = memref.load %alloca[%c1] : memref<6xf64>
    %12 = memref.load %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %13 = arith.addf %12, %11 : f64
    memref.store %13, %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %14 = memref.load %alloca[%c2] : memref<6xf64>
    %15 = memref.load %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %16 = arith.addf %15, %14 : f64
    memref.store %16, %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %17 = memref.load %alloca[%c3] : memref<6xf64>
    %18 = memref.load %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %19 = arith.addf %18, %17 : f64
    memref.store %19, %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %20 = memref.load %alloca[%c4] : memref<6xf64>
    %21 = memref.load %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %22 = arith.addf %21, %20 : f64
    memref.store %22, %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %23 = memref.load %alloca[%c5] : memref<6xf64>
    %24 = memref.load %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %25 = arith.addf %24, %23 : f64
    memref.store %25, %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    return
  }
}

