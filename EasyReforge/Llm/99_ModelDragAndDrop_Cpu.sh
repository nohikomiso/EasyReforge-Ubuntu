#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge LLM Model Drag-And-Drop Launcher (CPU)
# Launch llama-server with a specific GGUF model file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

echo "============================================================="
echo "Launch Variant: LLM Model Drag-And-Drop (CPU)"
echo "Usage: bash 99_ModelDragAndDrop_Cpu.sh [path_to_model.gguf] [extra_args...]"
echo "============================================================="

# If no arguments, prompt for model
if [ $# -eq 0 ]; then
    echo "Usage: bash $0 <path_to_gguf_model>"
    exit 1
fi

launch_server "$@"
