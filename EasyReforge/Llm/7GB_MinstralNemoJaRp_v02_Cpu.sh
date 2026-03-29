#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Model: mmnga/Minstral-Nemo-Japanese-RP-v0.2-GGUF (CPU)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

REPO="mmnga/Minstral-Nemo-Japanese-RP-v0.2-GGUF"
FILENAME="Minstral-Nemo-Japanese-RP-v0.2-Q4_K_M.gguf"

download_model "$REPO" "$FILENAME"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Cpu.sh" "${SCRIPT_DIR}/models/${FILENAME}" "$@"
