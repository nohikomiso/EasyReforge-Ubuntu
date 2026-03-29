#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/civitai_download.sh"

civitai_download "Lora/NoobE_Char" "Gqux_LalahSune_v10.safetensors" "1646974" "1864136"
