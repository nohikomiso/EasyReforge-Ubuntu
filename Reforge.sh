#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge NoOptions Launcher (Linux)
# This is the core launcher for Stable Diffusion WebUI (Reforge) on Ubuntu.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================="
echo "Launch Variant: No Options (Standard)"
echo "============================================================="

# Call the internal reforge.sh engine
if [ -f "${SCRIPT_DIR}/EasyReforge/reforge.sh" ]; then
    bash "${SCRIPT_DIR}/EasyReforge/reforge.sh" "$@"
else
    echo "[Error] ${SCRIPT_DIR}/EasyReforge/reforge.sh not found."
    exit 1
fi
