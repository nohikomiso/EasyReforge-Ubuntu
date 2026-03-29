#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Model: Undi95/Lumimaid-Magnum-v4-12B-GGUF (CPU)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

REPO="Undi95/Lumimaid-Magnum-v4-12B-GGUF"
FILENAME="Lumimaid-Magnum-v4-12B.q4_k_m.gguf"

download_model "$REPO" "$FILENAME"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Cpu.sh" "${SCRIPT_DIR}/models/${FILENAME}" "$@"
