#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge Dark Theme Launcher (Linux)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export COMMANDLINE_ARGS="--theme dark ${COMMANDLINE_ARGS:-}"

echo "============================================================="
echo "Launch Variant: Dark Theme"
echo "============================================================="

bash "${SCRIPT_DIR}/Reforge.sh" "$@"
