#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "Stable-diffusion/Illu" "songMix_v34.safetensors" "yyy1026/songMix" "songMix_v3.x/songMix_v3.4.safetensors"
