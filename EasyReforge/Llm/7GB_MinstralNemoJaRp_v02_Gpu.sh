#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Model: mmnga/Minstral-Nemo-Japanese-RP-v0.2-GGUF (GPU)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

REPO="mmnga/Minstral-Nemo-Japanese-RP-v0.2-GGUF"
FILENAME="Minstral-Nemo-Japanese-RP-v0.2-Q4_K_M.gguf"

# 12B model - adjust layers
export COMMANDLINE_ARGS="--n-gpu-layers 32 ${COMMANDLINE_ARGS:-}"

download_model "$REPO" "$FILENAME"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Gpu.sh" "${SCRIPT_DIR}/models/${FILENAME}" "$COMMANDLINE_ARGS" "$@"
