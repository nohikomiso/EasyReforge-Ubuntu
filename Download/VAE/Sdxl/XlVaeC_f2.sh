#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/civitai_download.sh"

civitai_download "VAE/Sdxl" "XlVaeC_f2.safetensors" "152040" "719135"
