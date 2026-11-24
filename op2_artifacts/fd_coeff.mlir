module {
  memref.global "private" constant @literal_0 : memref<36xf64> = dense<[-0.085259998073687129, -0.12434719365631872, -0.085259998073686907, 0.20960719173000558, -0.12434719365631874, 0.20960719173000544, 0.28743887558130077, 0.61140198570687221, 0.10115913871182751, 0.61140198570687221, 0.10115913871182751, 0.28743887558130077, 0.10115913871182762, 0.1011591387118275, 0.28743887558130055, 0.28743887558130066, 0.6114019857068721, 0.61140198570687221, 0.2096071917300055, 0.20960719173000547, -0.12434719365631877, -0.12434719365631876, -0.08525999807368706, -0.085259998073687102, 0.6114019857068721, 0.28743887558130066, 0.61140198570687221, 0.10115913871182751, 0.28743887558130066, 0.10115913871182751, -0.12434719365631877, -0.085259998073687046, 0.20960719173000558, -0.08525999807368706, 0.20960719173000555, -0.12434719365631876]>
  memref.global "private" constant @literal_1 : memref<6xf64> = dense<0.083333333333333329>
  memref.global "private" constant @literal_2 : memref<6xf64> = dense<[0.10903900907287703, 0.23193336855303107, 0.10903900907287707, 0.65902762237409196, 0.23193336855303098, 0.65902762237409185]>
  memref.global "private" constant @literal_3 : memref<6xf64> = dense<[0.65902762237409185, 0.65902762237409185, 0.23193336855303101, 0.23193336855303101, 0.10903900907287699, 0.10903900907287699]>
  memref.global "private" constant @literal_4 : memref<6xf64> = dense<[0.23193336855303101, 0.10903900907287699, 0.65902762237409185, 0.10903900907287699, 0.65902762237409185, 0.23193336855303101]>
  func.func private @fd_coeff(%arg0: memref<?xf64, strided<[?], offset: ?>>, %arg1: memref<?xf64, strided<[?], offset: ?>>, %arg2: memref<?xf64, strided<[?], offset: ?>>, %arg3: memref<?xf64, strided<[?], offset: ?>>, %arg4: memref<?xf64, strided<[?], offset: ?>>, %arg5: memref<?xf64, strided<[?], offset: ?>>, %arg6: memref<?xf64, strided<[?], offset: ?>>, %arg7: memref<?xf64, strided<[?], offset: ?>>, %arg8: memref<?xf64, strided<[?], offset: ?>>, %arg9: memref<?xf64, strided<[?], offset: ?>>, %arg10: memref<?xf64, strided<[?], offset: ?>>, %arg11: memref<?xf64, strided<[?], offset: ?>>, %arg12: memref<?xf64, strided<[?], offset: ?>>) attributes {op2.kernel_artifact_canonical_abi, op2.kernel_ir} {
    %cst = arith.constant 0.083333333333333329 : f64
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
    %alloca_3 = memref.alloca() : memref<3xf64>
    %alloca_4 = memref.alloca() : memref<1xf64>
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
    memref.store %6, %alloca_3[%c0] : memref<3xf64>
    %7 = memref.load %arg10[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %7, %alloca_3[%c1] : memref<3xf64>
    %8 = memref.load %arg11[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %8, %alloca_3[%c2] : memref<3xf64>
    %9 = memref.load %arg12[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %9, %alloca_4[%c0] : memref<1xf64>
    %10 = memref.get_global @literal_4 : memref<6xf64>
    %11 = memref.get_global @literal_3 : memref<6xf64>
    %12 = memref.get_global @literal_2 : memref<6xf64>
    %13 = memref.get_global @literal_0 : memref<36xf64>
    scf.for %arg13 = %c0 to %c6 step %c1 {
      %32 = scf.for %arg14 = %c0 to %c6 step %c1 iter_args(%arg15 = %cst_1) -> (f64) {
        %35 = arith.muli %arg13, %c6 : index
        %36 = arith.addi %35, %arg14 : index
        %37 = memref.load %13[%36] : memref<36xf64>
        %38 = memref.load %alloca_2[%c0] : memref<6xf64>
        %39 = arith.mulf %38, %cst_0 : f64
        %40 = memref.load %alloca_2[%c2] : memref<6xf64>
        %41 = arith.addf %39, %40 : f64
        %42 = memref.load %alloca_2[%c1] : memref<6xf64>
        %43 = arith.mulf %42, %cst_0 : f64
        %44 = memref.load %alloca_2[%c5] : memref<6xf64>
        %45 = arith.addf %43, %44 : f64
        %46 = arith.mulf %41, %45 : f64
        %47 = memref.load %alloca_2[%c0] : memref<6xf64>
        %48 = arith.mulf %47, %cst_0 : f64
        %49 = memref.load %alloca_2[%c4] : memref<6xf64>
        %50 = arith.addf %48, %49 : f64
        %51 = memref.load %alloca_2[%c1] : memref<6xf64>
        %52 = arith.mulf %51, %cst_0 : f64
        %53 = memref.load %alloca_2[%c3] : memref<6xf64>
        %54 = arith.addf %52, %53 : f64
        %55 = arith.mulf %50, %54 : f64
        %56 = arith.mulf %55, %cst_0 : f64
        %57 = arith.addf %46, %56 : f64
        %58 = math.absf %57 : f64
        %59 = arith.mulf %58, %cst : f64
        %60 = memref.load %12[%arg14] : memref<6xf64>
        %61 = memref.load %alloca_3[%c0] : memref<3xf64>
        %62 = arith.mulf %60, %61 : f64
        %63 = memref.load %11[%arg14] : memref<6xf64>
        %64 = memref.load %alloca_3[%c1] : memref<3xf64>
        %65 = arith.mulf %63, %64 : f64
        %66 = arith.addf %62, %65 : f64
        %67 = memref.load %10[%arg14] : memref<6xf64>
        %68 = memref.load %alloca_3[%c2] : memref<3xf64>
        %69 = arith.mulf %67, %68 : f64
        %70 = arith.addf %66, %69 : f64
        %71 = memref.load %alloca_4[%c0] : memref<1xf64>
        %72 = arith.mulf %70, %71 : f64
        %73 = arith.mulf %59, %72 : f64
        %74 = arith.mulf %37, %73 : f64
        %75 = arith.addf %arg15, %74 : f64
        scf.yield %75 : f64
      }
      %33 = memref.load %alloca[%arg13] : memref<6xf64>
      %34 = arith.addf %33, %32 : f64
      memref.store %34, %alloca[%arg13] : memref<6xf64>
    }
    %14 = memref.load %alloca[%c0] : memref<6xf64>
    %15 = memref.load %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %16 = arith.addf %15, %14 : f64
    memref.store %16, %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %17 = memref.load %alloca[%c1] : memref<6xf64>
    %18 = memref.load %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %19 = arith.addf %18, %17 : f64
    memref.store %19, %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %20 = memref.load %alloca[%c2] : memref<6xf64>
    %21 = memref.load %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %22 = arith.addf %21, %20 : f64
    memref.store %22, %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %23 = memref.load %alloca[%c3] : memref<6xf64>
    %24 = memref.load %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %25 = arith.addf %24, %23 : f64
    memref.store %25, %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %26 = memref.load %alloca[%c4] : memref<6xf64>
    %27 = memref.load %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %28 = arith.addf %27, %26 : f64
    memref.store %28, %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %29 = memref.load %alloca[%c5] : memref<6xf64>
    %30 = memref.load %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %31 = arith.addf %30, %29 : f64
    memref.store %31, %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    return
  }
}

