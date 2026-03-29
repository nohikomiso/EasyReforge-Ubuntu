#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "ControlNet/NoobE" "NoobE_DepthMidas_v11.safetensors" "Eugeoter/noob-sdxl-controlnet-depth_midas-v1-1" "diffusion_pytorch_model.fp16.safetensors"
