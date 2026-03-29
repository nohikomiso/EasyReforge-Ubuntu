#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge RTX 30 Series Launcher (Linux)
# Tailored for Ampere architecture.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Using scaled dot product attention without memory optimization if stable
export COMMANDLINE_ARGS="--opt-sdp-no-mem-attention --pin-shared-memory --cuda-malloc ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: RTX 30 Series Optimization"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge_NoOptions.sh" "$@"
