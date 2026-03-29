#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Reforge LLM Chat Interface Launcher (Linux)
# Wrapper for llama-server providing a web chat UI.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/llm_inference_base.sh"

echo "============================================================="
echo "Launch Variant: LLM Chat Interface (llama-server)"
echo "============================================================="

# Standard chat flags
export COMMANDLINE_ARGS="--chat-template chatml ${COMMANDLINE_ARGS:-}"

bash "${SCRIPT_DIR}/99_ModelDragAndDrop_Gpu.sh" "$@"
