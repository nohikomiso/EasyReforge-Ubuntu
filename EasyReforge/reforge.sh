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
    
    # [Workaround] Survival fix for deleted Stability AI and other repositories
    # Many legacy mirrors have been recently archived or deleted.
    export STABLE_DIFFUSION_REPO="${STABLE_DIFFUSION_REPO:-https://github.com/w-e-w/stablediffusion.git}"
    export K_DIFFUSION_REPO="${K_DIFFUSION_REPO:-https://github.com/crowsonkb/k-diffusion.git}"
    export TAMING_TRANSFORMERS_REPO="${TAMING_TRANSFORMERS_REPO:-https://github.com/CompVis/taming-transformers.git}"
    export CODEFORMER_REPO="${CODEFORMER_REPO:-https://github.com/sczhou/CodeFormer.git}"
    export BLIP_REPO="${BLIP_REPO:-https://github.com/salesforce/BLIP.git}"
    
    # Set up virtual environment location for uv
    local venv_dir
    venv_dir="$(pwd)/.venv"
    export VIRTUAL_ENV="$venv_dir"

    # [Compatibility Enforcement] Use Constraint File
    # This prevents any secondary installation (from launch.py or extensions) from breaking the environment.
    export PIP_CONSTRAINT="${SCRIPT_DIR}/Reforge/src/constraints.txt"
    export UV_CONSTRAINT="${SCRIPT_DIR}/Reforge/src/constraints.txt"

    # Try using TCMalloc (mimicking webui.sh behavior for performance)
    if [[ -z "${LD_PRELOAD:-}" ]]; then
        local tcmalloc_lib
        tcmalloc_lib=$(ldconfig -p | grep -P "libtcmalloc_minimal\.so\.\d" | head -n 1 | awk '{print $NF}')
        if [[ -n "$tcmalloc_lib" ]]; then
            echo "➔ [TCMalloc] Detected: $tcmalloc_lib"
            export LD_PRELOAD="$tcmalloc_lib"
        fi
    fi

    # Pass through command-line arguments (Add --gradio-allowed-path to fix image display issues on Linux/Snap)
    local final_args="${COMMANDLINE_ARGS:-} --gradio-allowed-path \"${REFORGE_ROOT}\" $*"
    
    echo ""
    echo "VIRTUAL_ENV: $VIRTUAL_ENV"
    echo "COMMANDLINE_ARGS: $final_args"
    echo "Executing: uv run python launch.py $final_args"
    echo ""
    echo "http://localhost:7860/"
    echo ""
    
    # Execute directly via uv to bypass webui.sh's slow pip checks
    uv run python launch.py $final_args
}

main "$@"
