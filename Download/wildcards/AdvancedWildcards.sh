#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/civitai_download_unzip.sh"

civitai_download_unzip "wildcards/Advanced" "50s-locations.txt" "70930" "75621"
civitai_download_unzip "wildcards/Advanced" "female-artisans.txt" "91214" "97211"
civitai_download_unzip "wildcards/Advanced" "female-guerilla-fighters.txt" "75246" "79987"
civitai_download_unzip "wildcards/Advanced" "maid-dresses-locations.txt" "76968" "81762"
civitai_download_unzip "wildcards/Advanced" "post-apocalyptic-locations.txt" "70264" "74962"
civitai_download_unzip "wildcards/Advanced" "science-fiction-locations.txt" "70905" "75600"
civitai_download_unzip "wildcards/Advanced" "WWII-locations.txt" "69537" "74201"
