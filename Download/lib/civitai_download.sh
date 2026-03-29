#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

# 引数の受け取り
# Windows 時代: call %CIVITAI_MODEL% <DIR> <FILE> <MODEL_ID> <VERSION_ID>
civitai_download() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"
    local version_id="$4"

    ensure_directory "$model_dir"

    log_info "Civitai Model ID: $model_id, Version ID: $version_id"

    # Python 公式ダウンローダーのみを使用 (uv 経由で実行)
    # これにより、ゴミの検知（MIME-type検証）と公式 SDK による取得が一本化されます
    uv run python3 "${SCRIPT_DIR}/civitai_download.py" \
        "$version_id" \
        "$model_dir" \
        "$filename" \
        --token "${CIVITAI_API_TOKEN:-}"
}

# スクリプトとして直接実行された場合
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 4 ]; then
        error "Usage: $0 <model_dir> <filename> <model_id> <version_id>"
    fi
    civitai_download "$@"
fi
