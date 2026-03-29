#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge LLM Model Drag-And-Drop Launcher (GPU)
# Launch llama-server with a specific GGUF model file and GPU offloading.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

echo "============================================================="
echo "Launch Variant: LLM Model Drag-And-Drop (GPU)"
echo "Usage: bash 99_ModelDragAndDrop_Gpu.sh [path_to_model.gguf] [extra_args...]"
echo "============================================================="

# If no arguments, error check
if [ $# -eq 0 ]; then
    echo "Usage: bash $0 <path_to_gguf_model>"
    exit 1
fi

# --n-gpu-layers: Number of layers to offload to GPU. -1 means all if possible.
# Most GGUF models support this via llama-server CLI.
export COMMANDLINE_ARGS="--n-gpu-layers 999 ${COMMANDLINE_ARGS:-}"

launch_server "$@" "$COMMANDLINE_ARGS"
