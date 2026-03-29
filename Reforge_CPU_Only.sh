#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge CPU-Only Launcher (Linux)
# For systems without a compatible GPU.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Standard WebUI flags for CPU execution
export COMMANDLINE_ARGS="--skip-torch-cuda-test --precision full --no-half --use-cpu all ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: CPU Only (Warning: Very Slow)"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge_NoOptions.sh" "$@"
