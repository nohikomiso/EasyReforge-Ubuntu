#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Model: Undi95/Lumimaid-Magnum-v4-12B-GGUF (GPU)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

REPO="Undi95/Lumimaid-Magnum-v4-12B-GGUF"
FILENAME="Lumimaid-Magnum-v4-12B.q4_k_m.gguf"

# Standard optimization for llama-server
# --n-gpu-layers 41 as per original .bat
export COMMANDLINE_ARGS="--n-gpu-layers 41 ${COMMANDLINE_ARGS:-}"

download_model "$REPO" "$FILENAME"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Gpu.sh" "${SCRIPT_DIR}/models/${FILENAME}" "$COMMANDLINE_ARGS" "$@"
