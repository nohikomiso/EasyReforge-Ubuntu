#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../lib/huggingface_download.sh"

huggingface_download "ControlNet/Pony" "AnyTest_PonyDim256_v40.safetensors" "2vXpSwA7/iroiro-lora" "test_controlnet2/CN-anytest_v4-marged_pn_dim256.safetensors"
