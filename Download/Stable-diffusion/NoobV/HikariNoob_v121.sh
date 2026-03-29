#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "Stable-diffusion/NoobV" "HikariNoob_v121.safetensors" "RedRayz/hikari_noob_v-pred_1.2.1" "Hikari_Noob_v-pred_1.2.1.safetensors"
