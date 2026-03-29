#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge Fast Launcher (Linux)
# Optimizes generation speed with specialized CUDA settings.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define optimization flags for fast generation
# Reforce specific: --use-sage-attention (if available)
# Standard: --pin-shared-memory --cuda-malloc --cuda-stream
export COMMANDLINE_ARGS="--pin-shared-memory --cuda-malloc --cuda-stream --use-sage-attention ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: Fast Optimization"
echo "Args: $COMMANDLINE_ARGS"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge.sh" "$@"
