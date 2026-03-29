#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REFORGE_WEBUI="${REFORGE_ROOT}/stable-diffusion-webui-reForge"

source "${REFORGE_ROOT}/EasyReforge/src/lib/github.sh"
source "${REFORGE_ROOT}/EasyReforge/src/lib/uv.sh"

setup_environment() {
    export LC_ALL=C.UTF-8
    export TRITON_CACHE="$HOME/.triton/cache"
    local current_user
    current_user=$(whoami)
    export TORCH_INDUCTOR_TEMP="$HOME/.cache/torch/inductor_${current_user}"
    mkdir -p "$TRITON_CACHE" "$TORCH_INDUCTOR_TEMP"
    # Clean cache as bat file does
    rm -rf "${TRITON_CACHE:?}/"*
    rm -rf "${TORCH_INDUCTOR_TEMP:?}/"*
}

clone_reforge_webui() {
    echo "Cloning/updating reForge WebUI..."
    github_clone_or_pull \
        "https://github.com/Panchovix/stable-diffusion-webui-reForge.git" \
        "$REFORGE_WEBUI"

    # Specific commit from original
    github_fetch_commit \
        "https://github.com/Panchovix/stable-diffusion-webui-reForge.git" \
        "19395bf96ccdc605774c76a9fe8cc7145b637128" \
        "$REFORGE_WEBUI"
}

setup_python_venv() {
    echo "Setting up Python virtual environment..."
    cd "$REFORGE_WEBUI"
    # Get venv path via uv tool
    VENV_DIR=$(bash "${REFORGE_ROOT}/EasyReforge/src/lib/uv.sh" ./.venv)
    export VIRTUAL_ENV="$VENV_DIR"
    
    # Ensure pip/setuptools are updated
    VIRTUAL_ENV="$VENV_DIR" uv pip install -U pip setuptools wheel
}

get_cuda_version() {
    if command -v nvidia-smi &>/dev/null; then
        nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -1
    else
        echo "cpu"
    fi
}

install_pytorch() {
    echo "Installing PyTorch..."
    cd "$REFORGE_WEBUI"
    local cuda_ver
    cuda_ver=$(get_cuda_version)

    if [ "$cuda_ver" = "cpu" ]; then
        VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cpu
    else
        # Use cu128 as specified in the Windows version
        VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install torch==2.7.1 torchvision==0.22.1+cu128 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu128
    fi
}

install_wheels() {
    echo "Installing wheels..."
    cd "$REFORGE_WEBUI"

    # SageAttention
    if [ -f "${SCRIPT_DIR}/wheels/sageattention-2.2.0-cp310-cp310-linux_x86_64.whl" ]; then
        VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install "${SCRIPT_DIR}/wheels/sageattention-2.2.0-cp310-cp310-linux_x86_64.whl" || true
    else
        VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install "sageattention[all]" --no-binary sageattention || true
    fi

    # llama-cpp-python
    # Phase 2 doc says we should try building with CUDA
    CMAKE_ARGS="-DLLAMA_CUBLAS=on" VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install llama-cpp-python==0.3.4 || \
        VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install llama-cpp-python==0.3.4 || true
}

install_requirements() {
    echo "Installing requirements..."
    cd "$REFORGE_WEBUI"
    local req_file="${SCRIPT_DIR}/src/requirements.txt"
    
    # Ensure requirements exists
    if [ ! -f "$req_file" ]; then
        echo "Error: Requirements file not found at $req_file"
        exit 1
    fi
    
    # Create a temporary copy to strip windows specific packages
    local tmp_req
    tmp_req=$(mktemp)
    cp "$req_file" "$tmp_req"
    
    # Remove Windows-specific packages
    sed -i '/^pywin32/d' "$tmp_req"
    sed -i '/^pyreadline3/d' "$tmp_req"
    sed -i '/^triton-windows/d' "$tmp_req"

    VIRTUAL_ENV="$VIRTUAL_ENV" uv pip install -r "$tmp_req"
    rm "$tmp_req"
}

copy_src_files() {
    echo "Copying source files..."
    local src_dir="${SCRIPT_DIR}/src/stable-diffusion-webui-reForge"
    if [ -d "$src_dir" ]; then
        rsync -av "$src_dir"/ "$REFORGE_WEBUI"/
    fi
}

main() {
    setup_environment
    clone_reforge_webui
    setup_python_venv
    install_pytorch
    install_wheels
    install_requirements
    copy_src_files
    
    echo "reforge.sh completed successfully."
}

main "$@"
