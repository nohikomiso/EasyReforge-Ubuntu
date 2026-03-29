#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "Stable-diffusion/NoobV" "HarmoniqMixSpo_v30.safetensors" "hybskgks28275/HarmoniqMix_vPred_v3.x" "HarmoniqMix_vPred_v3_SPO/HarmoniqMix_vPred_v3_SPO.safetensors"
