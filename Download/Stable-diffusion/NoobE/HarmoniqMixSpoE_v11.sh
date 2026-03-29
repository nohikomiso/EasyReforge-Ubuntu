#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "Stable-diffusion/NoobE" "HarmoniqMixSpoE_v11.safetensors" "hybskgks28275/HarmoniqMix_ePred_v1.x" "HarmoniqMix_ePred_v11_SPO/HarmoniqMix_ePred_v11_SPO.safetensors"
