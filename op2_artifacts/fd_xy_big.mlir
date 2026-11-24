module {
  memref.global "private" constant @literal_0 : memref<36xf64> = dense<[-0.048208377815511905, -0.08473049309397801, -0.048208377815511981, 0.51763234198767183, -0.074803807748196213, -0.074803807748196366, 0.79548022620090586, 0.19283351126204828, 0.19283351126204762, 0.29921523099278774, 0.2992152309927853, 0.03354481152314847, 0.19283351126204795, 0.19283351126204815, 0.7954802262009063, 0.29921523099278491, 0.033544811523148477, 0.29921523099278641, -0.04820837781551196, -0.048208377815511828, -0.084730493093977788, -0.074803807748196824, 0.51763234198767238, -0.074803807748196394, 0.19283351126204804, 0.79548022620090575, 0.19283351126204776, 0.033544811523148553, 0.29921523099278674, 0.29921523099278563, -0.084730493093977857, -0.048208377815512293, -0.048208377815511717, -0.074803807748196297, -0.074803807748196616, 0.51763234198767227]>
  memref.global "private" constant @literal_1 : memref<6xf64> = dense<[0.1116907948390056, 0.1116907948390056, 0.1116907948390056, 0.054975871827660797, 0.054975871827660797, 0.054975871827660797]>
  memref.global "private" constant @literal_2 : memref<6xf64> = dense<[0.44594849091596495, 0.10810301816807018, 0.44594849091596489, 0.81684757298045818, 0.091576213509770646, 0.091576213509771048]>
  memref.global "private" constant @literal_3 : memref<6xf64> = dense<[0.44594849091596489, 0.44594849091596511, 0.10810301816806987, 0.091576213509771284, 0.81684757298045829, 0.091576213509770618]>
  memref.global "private" constant @literal_4 : memref<6xf64> = dense<[0.10810301816807009, 0.44594849091596461, 0.44594849091596522, 0.091576213509770396, 0.091576213509770965, 0.81684757298045829]>
  func.func private @fd_xy_big(%arg0: memref<?xf64, strided<[?], offset: ?>>, %arg1: memref<?xf64, strided<[?], offset: ?>>, %arg2: memref<?xf64, strided<[?], offset: ?>>, %arg3: memref<?xf64, strided<[?], offset: ?>>, %arg4: memref<?xf64, strided<[?], offset: ?>>, %arg5: memref<?xf64, strided<[?], offset: ?>>, %arg6: memref<?xf64, strided<[?], offset: ?>>, %arg7: memref<?xf64, strided<[?], offset: ?>>, %arg8: memref<?xf64, strided<[?], offset: ?>>) attributes {op2.kernel_artifact_canonical_abi, op2.kernel_ir} {
    %c6 = arith.constant 6 : index
    %cst = arith.constant -1.000000e+00 : f64
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %cst_0 = arith.constant 0.000000e+00 : f64
    %alloca = memref.alloca() : memref<6xf64>
    memref.store %cst_0, %alloca[%c0] : memref<6xf64>
    memref.store %cst_0, %alloca[%c1] : memref<6xf64>
    memref.store %cst_0, %alloca[%c2] : memref<6xf64>
    memref.store %cst_0, %alloca[%c3] : memref<6xf64>
    memref.store %cst_0, %alloca[%c4] : memref<6xf64>
    memref.store %cst_0, %alloca[%c5] : memref<6xf64>
    %alloca_1 = memref.alloca() : memref<6xf64>
    %0 = memref.load %arg6[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %0, %alloca_1[%c0] : memref<6xf64>
    %1 = memref.load %arg6[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %1, %alloca_1[%c1] : memref<6xf64>
    %2 = memref.load %arg7[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %2, %alloca_1[%c2] : memref<6xf64>
    %3 = memref.load %arg7[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %3, %alloca_1[%c3] : memref<6xf64>
    %4 = memref.load %arg8[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %4, %alloca_1[%c4] : memref<6xf64>
    %5 = memref.load %arg8[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %5, %alloca_1[%c5] : memref<6xf64>
    %6 = memref.get_global @literal_4 : memref<6xf64>
    %7 = memref.get_global @literal_3 : memref<6xf64>
    %8 = memref.get_global @literal_2 : memref<6xf64>
    %9 = memref.get_global @literal_1 : memref<6xf64>
    %10 = memref.get_global @literal_0 : memref<36xf64>
    scf.for %arg9 = %c0 to %c6 step %c1 {
      %29 = scf.for %arg10 = %c0 to %c6 step %c1 iter_args(%arg11 = %cst_0) -> (f64) {
        %32 = arith.muli %arg9, %c6 : index
        %33 = arith.addi %32, %arg10 : index
        %34 = memref.load %10[%33] : memref<36xf64>
        %35 = memref.load %9[%arg10] : memref<6xf64>
        %36 = memref.load %alloca_1[%c0] : memref<6xf64>
        %37 = arith.mulf %36, %cst : f64
        %38 = memref.load %alloca_1[%c2] : memref<6xf64>
        %39 = arith.addf %37, %38 : f64
        %40 = memref.load %alloca_1[%c1] : memref<6xf64>
        %41 = arith.mulf %40, %cst : f64
        %42 = memref.load %alloca_1[%c5] : memref<6xf64>
        %43 = arith.addf %41, %42 : f64
        %44 = arith.mulf %39, %43 : f64
        %45 = memref.load %alloca_1[%c0] : memref<6xf64>
        %46 = arith.mulf %45, %cst : f64
        %47 = memref.load %alloca_1[%c4] : memref<6xf64>
        %48 = arith.addf %46, %47 : f64
        %49 = memref.load %alloca_1[%c1] : memref<6xf64>
        %50 = arith.mulf %49, %cst : f64
        %51 = memref.load %alloca_1[%c3] : memref<6xf64>
        %52 = arith.addf %50, %51 : f64
        %53 = arith.mulf %48, %52 : f64
        %54 = arith.mulf %53, %cst : f64
        %55 = arith.addf %44, %54 : f64
        %56 = math.absf %55 : f64
        %57 = arith.mulf %35, %56 : f64
        %58 = memref.load %8[%arg10] : memref<6xf64>
        %59 = memref.load %alloca_1[%c0] : memref<6xf64>
        %60 = arith.mulf %58, %59 : f64
        %61 = memref.load %7[%arg10] : memref<6xf64>
        %62 = memref.load %alloca_1[%c2] : memref<6xf64>
        %63 = arith.mulf %61, %62 : f64
        %64 = arith.addf %60, %63 : f64
        %65 = memref.load %6[%arg10] : memref<6xf64>
        %66 = memref.load %alloca_1[%c4] : memref<6xf64>
        %67 = arith.mulf %65, %66 : f64
        %68 = arith.addf %64, %67 : f64
        %69 = memref.load %8[%arg10] : memref<6xf64>
        %70 = memref.load %alloca_1[%c1] : memref<6xf64>
        %71 = arith.mulf %69, %70 : f64
        %72 = memref.load %7[%arg10] : memref<6xf64>
        %73 = memref.load %alloca_1[%c3] : memref<6xf64>
        %74 = arith.mulf %72, %73 : f64
        %75 = arith.addf %71, %74 : f64
        %76 = memref.load %6[%arg10] : memref<6xf64>
        %77 = memref.load %alloca_1[%c5] : memref<6xf64>
        %78 = arith.mulf %76, %77 : f64
        %79 = arith.addf %75, %78 : f64
        %80 = arith.mulf %68, %79 : f64
        %81 = arith.mulf %57, %80 : f64
        %82 = arith.mulf %34, %81 : f64
        %83 = arith.addf %arg11, %82 : f64
        scf.yield %83 : f64
      }
      %30 = memref.load %alloca[%arg9] : memref<6xf64>
      %31 = arith.addf %30, %29 : f64
      memref.store %31, %alloca[%arg9] : memref<6xf64>
    }
    %11 = memref.load %alloca[%c0] : memref<6xf64>
    %12 = memref.load %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %13 = arith.addf %12, %11 : f64
    memref.store %13, %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %14 = memref.load %alloca[%c1] : memref<6xf64>
    %15 = memref.load %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %16 = arith.addf %15, %14 : f64
    memref.store %16, %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %17 = memref.load %alloca[%c2] : memref<6xf64>
    %18 = memref.load %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %19 = arith.addf %18, %17 : f64
    memref.store %19, %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %20 = memref.load %alloca[%c3] : memref<6xf64>
    %21 = memref.load %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %22 = arith.addf %21, %20 : f64
    memref.store %22, %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %23 = memref.load %alloca[%c4] : memref<6xf64>
    %24 = memref.load %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %25 = arith.addf %24, %23 : f64
    memref.store %25, %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %26 = memref.load %alloca[%c5] : memref<6xf64>
    %27 = memref.load %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %28 = arith.addf %27, %26 : f64
    memref.store %28, %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    return
  }
}

