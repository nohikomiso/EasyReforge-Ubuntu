#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "VAE/Sdxl" "songVae_v10.safetensors" "yyy1026/songMix" "VAE_songVAE_v1.safetensors"
