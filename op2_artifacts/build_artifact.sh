#!/usr/bin/env bash
# Package <kernel>.mlir + <kernel>.h into an OP2 canonical artifact:
#   <kernel>.mlirbc  (MLIR bytecode)  and  <kernel>.json  (manifest).
# Usage: ./build_artifact.sh fd_scale
set -euo pipefail
cd "$(dirname "$0")"
K="${1:?kernel name}"
MLIR_OPT="$(brew --prefix llvm)/bin/mlir-opt"
"$MLIR_OPT" "$K.mlir" --emit-bytecode -o "$K.mlirbc"
SRC="$(pwd)/$K.h"
DIGEST="$(shasum -a 256 "$SRC" | cut -d' ' -f1)"
cat > "$K.json" <<JSON
{
  "format_version": 1,
  "language": "cpp",
  "kernel": "$K",
  "source": "$SRC",
  "source_digest": "$DIGEST",
  "constants": []
}
JSON
echo "built $K.mlirbc and $K.json"
