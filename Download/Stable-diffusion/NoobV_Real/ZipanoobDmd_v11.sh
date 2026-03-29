#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "Stable-diffusion/NoobV_Real" "ZipanoobDmd_v11.safetensors" "deadman44/SDXL_Photoreal_Merged_Models" "Zipanoob_XL_Vpred_v1.1.safetensors"
