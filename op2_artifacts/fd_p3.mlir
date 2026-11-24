module {
  memref.global "private" constant @literal_0 : memref<70xf64> = dense<[0.16153718838377484, 0.063367962698312214, 0.063367962698312075, -0.10224065463222831, 0.056149886446157697, -0.1022406546322286, 0.000000e+00, 0.45488022336968414, -0.17374878451707448, -0.03570837463895233, 0.45358981292855333, -0.093220536865818895, 0.035607076633230206, 0.000000e+00, -0.17374878451707476, 0.45488022336968215, -0.035708374638952427, 0.45358981292855327, 0.03560707663323015, -0.093220536865818882, 0.000000e+00, 0.22088075779228963, 0.22088075779229013, 0.22088075779228949, 0.35637871742637001, 0.35637871742636901, 0.35637871742636879, 1.000000e+00, 0.45488022336968104, -0.035708374638952559, -0.17374878451707459, 0.035607076633230414, -0.093220536865818937, 0.45358981292855372, 0.000000e+00, -0.17374878451707426, -0.035708374638952413, 0.45488022336968353, -0.093220536865819214, 0.035607076633230296, 0.45358981292855433, 0.000000e+00, 0.063367962698312158, 0.16153718838377423, 0.063367962698312075, -0.10224065463222839, -0.10224065463222851, 0.056149886446157586, 0.000000e+00, -0.035708374638952392, 0.45488022336968326, -0.17374878451707429, 0.035607076633230372, 0.45358981292855333, -0.093220536865818909, 0.000000e+00, -0.035708374638952455, -0.17374878451707465, 0.45488022336968159, -0.093220536865819214, 0.45358981292855438, 0.035607076633230303, 0.000000e+00, 0.063367962698311991, 0.063367962698312047, 0.16153718838377507, 0.056149886446157732, -0.10224065463222864, -0.1022406546322286, 0.000000e+00]>
  memref.global "private" constant @literal_1 : memref<7xf64> = dense<[0.062969590272413709, 0.062969590272413709, 0.062969590272413709, 0.066197076394253221, 0.066197076394253221, 0.066197076394253221, 0.11250000000000014]>
  memref.global "private" constant @literal_2 : memref<7xf64> = dense<[0.79742698535308754, 0.10128650732345627, 0.10128650732345636, 0.47014206410511494, 0.059715871789769982, 0.47014206410511483, 0.33333333333333337]>
  memref.global "private" constant @literal_3 : memref<7xf64> = dense<[0.10128650732345655, 0.7974269853530872, 0.10128650732345601, 0.47014206410511494, 0.47014206410511478, 0.05971587178976983, 0.33333333333333315]>
  memref.global "private" constant @literal_4 : memref<7xf64> = dense<[0.10128650732345588, 0.10128650732345643, 0.79742698535308754, 0.059715871789770052, 0.47014206410511516, 0.47014206410511516, 0.33333333333333337]>
  func.func private @fd_p3(%arg0: memref<?xf64, strided<[?], offset: ?>>, %arg1: memref<?xf64, strided<[?], offset: ?>>, %arg2: memref<?xf64, strided<[?], offset: ?>>, %arg3: memref<?xf64, strided<[?], offset: ?>>, %arg4: memref<?xf64, strided<[?], offset: ?>>, %arg5: memref<?xf64, strided<[?], offset: ?>>, %arg6: memref<?xf64, strided<[?], offset: ?>>, %arg7: memref<?xf64, strided<[?], offset: ?>>, %arg8: memref<?xf64, strided<[?], offset: ?>>, %arg9: memref<?xf64, strided<[?], offset: ?>>, %arg10: memref<?xf64, strided<[?], offset: ?>>, %arg11: memref<?xf64, strided<[?], offset: ?>>, %arg12: memref<?xf64, strided<[?], offset: ?>>) attributes {op2.kernel_artifact_canonical_abi, op2.kernel_ir} {
    %c10 = arith.constant 10 : index
    %cst = arith.constant -1.000000e+00 : f64
    %c9 = arith.constant 9 : index
    %c8 = arith.constant 8 : index
    %c7 = arith.constant 7 : index
    %c6 = arith.constant 6 : index
    %c5 = arith.constant 5 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %cst_0 = arith.constant 0.000000e+00 : f64
    %alloca = memref.alloca() : memref<10xf64>
    memref.store %cst_0, %alloca[%c0] : memref<10xf64>
    memref.store %cst_0, %alloca[%c1] : memref<10xf64>
    memref.store %cst_0, %alloca[%c2] : memref<10xf64>
    memref.store %cst_0, %alloca[%c3] : memref<10xf64>
    memref.store %cst_0, %alloca[%c4] : memref<10xf64>
    memref.store %cst_0, %alloca[%c5] : memref<10xf64>
    memref.store %cst_0, %alloca[%c6] : memref<10xf64>
    memref.store %cst_0, %alloca[%c7] : memref<10xf64>
    memref.store %cst_0, %alloca[%c8] : memref<10xf64>
    memref.store %cst_0, %alloca[%c9] : memref<10xf64>
    %alloca_1 = memref.alloca() : memref<6xf64>
    %0 = memref.load %arg10[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %0, %alloca_1[%c0] : memref<6xf64>
    %1 = memref.load %arg10[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %1, %alloca_1[%c1] : memref<6xf64>
    %2 = memref.load %arg11[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %2, %alloca_1[%c2] : memref<6xf64>
    %3 = memref.load %arg11[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %3, %alloca_1[%c3] : memref<6xf64>
    %4 = memref.load %arg12[%c0] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %4, %alloca_1[%c4] : memref<6xf64>
    %5 = memref.load %arg12[%c1] : memref<?xf64, strided<[?], offset: ?>>
    memref.store %5, %alloca_1[%c5] : memref<6xf64>
    %6 = memref.get_global @literal_4 : memref<7xf64>
    %7 = memref.get_global @literal_3 : memref<7xf64>
    %8 = memref.get_global @literal_2 : memref<7xf64>
    %9 = memref.get_global @literal_1 : memref<7xf64>
    %10 = memref.get_global @literal_0 : memref<70xf64>
    scf.for %arg13 = %c0 to %c10 step %c1 {
      %41 = scf.for %arg14 = %c0 to %c7 step %c1 iter_args(%arg15 = %cst_0) -> (f64) {
        %44 = arith.muli %arg13, %c7 : index
        %45 = arith.addi %44, %arg14 : index
        %46 = memref.load %10[%45] : memref<70xf64>
        %47 = memref.load %9[%arg14] : memref<7xf64>
        %48 = memref.load %alloca_1[%c0] : memref<6xf64>
        %49 = arith.mulf %48, %cst : f64
        %50 = memref.load %alloca_1[%c2] : memref<6xf64>
        %51 = arith.addf %49, %50 : f64
        %52 = memref.load %alloca_1[%c1] : memref<6xf64>
        %53 = arith.mulf %52, %cst : f64
        %54 = memref.load %alloca_1[%c5] : memref<6xf64>
        %55 = arith.addf %53, %54 : f64
        %56 = arith.mulf %51, %55 : f64
        %57 = memref.load %alloca_1[%c0] : memref<6xf64>
        %58 = arith.mulf %57, %cst : f64
        %59 = memref.load %alloca_1[%c4] : memref<6xf64>
        %60 = arith.addf %58, %59 : f64
        %61 = memref.load %alloca_1[%c1] : memref<6xf64>
        %62 = arith.mulf %61, %cst : f64
        %63 = memref.load %alloca_1[%c3] : memref<6xf64>
        %64 = arith.addf %62, %63 : f64
        %65 = arith.mulf %60, %64 : f64
        %66 = arith.mulf %65, %cst : f64
        %67 = arith.addf %56, %66 : f64
        %68 = math.absf %67 : f64
        %69 = arith.mulf %47, %68 : f64
        %70 = memref.load %8[%arg14] : memref<7xf64>
        %71 = memref.load %alloca_1[%c0] : memref<6xf64>
        %72 = arith.mulf %70, %71 : f64
        %73 = memref.load %7[%arg14] : memref<7xf64>
        %74 = memref.load %alloca_1[%c2] : memref<6xf64>
        %75 = arith.mulf %73, %74 : f64
        %76 = arith.addf %72, %75 : f64
        %77 = memref.load %6[%arg14] : memref<7xf64>
        %78 = memref.load %alloca_1[%c4] : memref<6xf64>
        %79 = arith.mulf %77, %78 : f64
        %80 = arith.addf %76, %79 : f64
        %81 = memref.load %8[%arg14] : memref<7xf64>
        %82 = memref.load %alloca_1[%c1] : memref<6xf64>
        %83 = arith.mulf %81, %82 : f64
        %84 = memref.load %7[%arg14] : memref<7xf64>
        %85 = memref.load %alloca_1[%c3] : memref<6xf64>
        %86 = arith.mulf %84, %85 : f64
        %87 = arith.addf %83, %86 : f64
        %88 = memref.load %6[%arg14] : memref<7xf64>
        %89 = memref.load %alloca_1[%c5] : memref<6xf64>
        %90 = arith.mulf %88, %89 : f64
        %91 = arith.addf %87, %90 : f64
        %92 = arith.mulf %80, %91 : f64
        %93 = arith.mulf %69, %92 : f64
        %94 = arith.mulf %46, %93 : f64
        %95 = arith.addf %arg15, %94 : f64
        scf.yield %95 : f64
      }
      %42 = memref.load %alloca[%arg13] : memref<10xf64>
      %43 = arith.addf %42, %41 : f64
      memref.store %43, %alloca[%arg13] : memref<10xf64>
    }
    %11 = memref.load %alloca[%c0] : memref<10xf64>
    %12 = memref.load %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %13 = arith.addf %12, %11 : f64
    memref.store %13, %arg0[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %14 = memref.load %alloca[%c1] : memref<10xf64>
    %15 = memref.load %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %16 = arith.addf %15, %14 : f64
    memref.store %16, %arg1[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %17 = memref.load %alloca[%c2] : memref<10xf64>
    %18 = memref.load %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %19 = arith.addf %18, %17 : f64
    memref.store %19, %arg2[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %20 = memref.load %alloca[%c3] : memref<10xf64>
    %21 = memref.load %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %22 = arith.addf %21, %20 : f64
    memref.store %22, %arg3[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %23 = memref.load %alloca[%c4] : memref<10xf64>
    %24 = memref.load %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %25 = arith.addf %24, %23 : f64
    memref.store %25, %arg4[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %26 = memref.load %alloca[%c5] : memref<10xf64>
    %27 = memref.load %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %28 = arith.addf %27, %26 : f64
    memref.store %28, %arg5[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %29 = memref.load %alloca[%c6] : memref<10xf64>
    %30 = memref.load %arg6[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %31 = arith.addf %30, %29 : f64
    memref.store %31, %arg6[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %32 = memref.load %alloca[%c7] : memref<10xf64>
    %33 = memref.load %arg7[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %34 = arith.addf %33, %32 : f64
    memref.store %34, %arg7[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %35 = memref.load %alloca[%c8] : memref<10xf64>
    %36 = memref.load %arg8[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %37 = arith.addf %36, %35 : f64
    memref.store %37, %arg8[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %38 = memref.load %alloca[%c9] : memref<10xf64>
    %39 = memref.load %arg9[%c0] : memref<?xf64, strided<[?], offset: ?>>
    %40 = arith.addf %39, %38 : f64
    memref.store %40, %arg9[%c0] : memref<?xf64, strided<[?], offset: ?>>
    return
  }
}

