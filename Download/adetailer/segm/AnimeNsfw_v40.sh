#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/civitai_download_unzip.sh"

civitai_download_unzip "adetailer/segm" "ntd11_anime_nsfw_segm_v4_all.pt" "1313556" "1863248"
