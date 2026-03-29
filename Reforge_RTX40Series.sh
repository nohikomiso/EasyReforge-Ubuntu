#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge RTX 40/50 Series Launcher (Linux)
# Tailored for Ada Lovelace and Blackwell architectures.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Specialized optimizations for newer architecture
export COMMANDLINE_ARGS="--opt-sdp-attention --pin-shared-memory --cuda-malloc --cuda-stream ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: RTX 40/50 Series Optimization"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge_NoOptions.sh" "$@"
