#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REFORGE_WEBUI="${REFORGE_ROOT}/stable-diffusion-webui-reForge"

main() {
    echo "============================================================="
    echo "Updating reForge Configuration"
    echo "============================================================="
    
    cd "$REFORGE_WEBUI"
    
    local py_script="${SCRIPT_DIR}/src/reforge_update_config.py"
    if [ ! -f "$py_script" ]; then
        echo "Error: Configuration script not found at $py_script"
        exit 1
    fi
    
    # Ensure virtual environment exists
    if [ ! -d "./.venv" ]; then
        echo "Error: Virtual environment not found in $REFORGE_WEBUI"
        exit 1
    fi
    
    # Use uv run directly with .venv, using default config.json if no arguments are passed
    local target_config="${1:-}"
    if [ -z "$target_config" ]; then
        target_config="${REFORGE_WEBUI}/config.json"
    fi
    
    local venv_dir
    venv_dir="$(pwd)/.venv"
    export VIRTUAL_ENV="$venv_dir"
    uv run python "$py_script" "$target_config"
    
    echo "Configuration updated successfully."
}

main "$@"
