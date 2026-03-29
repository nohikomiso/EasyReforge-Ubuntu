#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REFORGE_WEBUI="${REFORGE_ROOT}/stable-diffusion-webui-reForge"

main() {
    # 1. Ensure the environment is present
    if [ ! -d "${REFORGE_WEBUI}/.venv" ]; then
        echo "[Error] ${REFORGE_WEBUI}/.venv/ が見つかりません。先にインストーラー(setup.sh)を実行してください。"
        exit 1
    fi

    # 1.5. Prepare reForge for launch (GPU Detection & Link validation)
    # This replaces the need for specific RTX30/40 launchers.
    echo "============================================================="
    echo "Preparing reForge for launch"
    echo "============================================================="
    
    # Check for symlinks validity
    # shellcheck disable=SC1091
    if [ -f "${SCRIPT_DIR}/Reforge/reforge_link.sh" ]; then
        bash "${SCRIPT_DIR}/Reforge/reforge_link.sh"
    fi

    # Automatically detect GPU optimizations
    # shellcheck disable=SC1091
    if [ -f "${SCRIPT_DIR}/Reforge/reforge_gpu_detect.sh" ]; then
        source "${SCRIPT_DIR}/Reforge/reforge_gpu_detect.sh"
    fi

    # 2. Update configurations using the newly created scripts
    bash "${SCRIPT_DIR}/Reforge/reforge_config.sh" "${REFORGE_WEBUI}/config.json"
    bash "${SCRIPT_DIR}/Reforge/reforge_ui_config.sh" "${REFORGE_WEBUI}/ui-config.json"

    # 3. Copy styles.csv if it doesn't exist
    if [ ! -f "${REFORGE_WEBUI}/styles.csv" ]; then
        echo "Copying default styles.csv..."
        cp "${SCRIPT_DIR}/Reforge/src/styles.csv" "${REFORGE_WEBUI}/styles.csv"
    fi

    # 4. Launch WebUI
    cd "$REFORGE_WEBUI"
    
    # Set up virtual environment location for the webui.sh
    local venv_dir
    venv_dir="$(pwd)/.venv"
    export VIRTUAL_ENV="$venv_dir"
    export PYTHON="python3" # WebUI uses python3 inside the venv
    
    # Pass through command-line arguments to COMMANDLINE_ARGS
    if [ -z "${COMMANDLINE_ARGS:-}" ]; then
        export COMMANDLINE_ARGS="$*"
    else
        export COMMANDLINE_ARGS="${COMMANDLINE_ARGS} $*"
    fi
    
    echo ""
    echo "VIRTUAL_ENV: $VIRTUAL_ENV"
    echo "COMMANDLINE_ARGS: $COMMANDLINE_ARGS"
    echo "Executing: bash webui.sh $COMMANDLINE_ARGS"
    echo ""
    echo "http://localhost:7860/"
    echo ""
    
    # Execute the actual reForge webui.sh
    bash "webui.sh"
}

main "$@"
