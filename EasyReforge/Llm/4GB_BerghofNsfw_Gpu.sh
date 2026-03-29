#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Model: mlabonne/Berghof-NSFW-7B-v1.0-GGUF (GPU)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

REPO="mlabonne/Berghof-NSFW-7B-v1.0-GGUF"
FILENAME="Berghof-NSFW-7B-v1.0.Q4_K_M.gguf"

# Standard optimization for 7B models
export COMMANDLINE_ARGS="--n-gpu-layers 33 ${COMMANDLINE_ARGS:-}"

download_model "$REPO" "$FILENAME"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Gpu.sh" "${SCRIPT_DIR}/models/${FILENAME}" "$COMMANDLINE_ARGS" "$@"
