#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REFORGE_WEBUI="${REFORGE_ROOT}/stable-diffusion-webui-reForge"

main() {
    echo "============================================================="
    echo "Updating reForge UI Configuration"
    echo "============================================================="
    
    cd "$REFORGE_WEBUI"
    
    local py_script="${SCRIPT_DIR}/src/reforge_update_ui-config.py"
    if [ ! -f "$py_script" ]; then
        echo "Error: UI Configuration script not found at $py_script"
        exit 1
    fi
    
    # Ensure virtual environment exists
    if [ ! -d "./.venv" ]; then
        echo "Error: Virtual environment not found in $REFORGE_WEBUI"
        exit 1
    fi
    
    # Use uv run directly with .venv, using default ui-config.json if no arguments are passed
    local target_config="${1:-}"
    if [ -z "$target_config" ]; then
        target_config="${REFORGE_WEBUI}/ui-config.json"
    fi
    
    local venv_dir
    venv_dir="$(pwd)/.venv"
    export VIRTUAL_ENV="$venv_dir"
    uv run python "$py_script" "$target_config"
    
    echo "UI Configuration updated successfully."
}

main "$@"
