#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge Low-VRAM Launcher (Linux)
# Optimizes for GPUs with limited video memory (e.g. < 12GB).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Aggressive vram management
export COMMANDLINE_ARGS="--lowvram --opt-split-attention --pin-shared-memory ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: Low-VRAM Optimization"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge.sh" "$@"
