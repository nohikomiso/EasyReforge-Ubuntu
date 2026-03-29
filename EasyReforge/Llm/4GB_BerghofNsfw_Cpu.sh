#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Model: mlabonne/Berghof-NSFW-7B-v1.0-GGUF (CPU)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

REPO="mlabonne/Berghof-NSFW-7B-v1.0-GGUF"
FILENAME="Berghof-NSFW-7B-v1.0.Q4_K_M.gguf"

download_model "$REPO" "$FILENAME"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Cpu.sh" "${SCRIPT_DIR}/models/${FILENAME}" "$@"
