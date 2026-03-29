#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge A100/H100 Launcher (Linux)
# High-end server GPU optimization.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Maximum throughput flags
export COMMANDLINE_ARGS="--xformers --pin-shared-memory --cuda-malloc --cuda-stream --use-sage-attention ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: High-End GPU (A100/H100) Max Throughput"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge_NoOptions.sh" "$@"
