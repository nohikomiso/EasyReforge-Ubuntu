#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/civitai_download.sh"

# 引数の受け取り
# Windows 時代: call %CIVITAI_MODEL_UNZIP% <DIR> <FILE> <MODEL_ID> <VERSION_ID>
civitai_download_unzip() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"
    local version_id="$4"

    ensure_directory "$model_dir"

    local temp_zip="${model_dir}/temp_civitai_${model_id}_${version_id}.zip"

    # ZIPとしてダウンロード (内部で正式APIトークン利用)
    civitai_download "$model_dir" "$(basename "$temp_zip")" "$model_id" "$version_id"

    # 解凍
    log_info "Extracting $temp_zip to $model_dir"
    
    if is_dry_run; then
        log_info "[DRY-RUN] Would unzip: $temp_zip"
    else
        unzip -o -q "$temp_zip" -d "$model_dir" || error "Extraction failed for $temp_zip with error code $?."
        # ZIP削除
        rm -f "$temp_zip"
    fi

    log_info "Successfully extracted: $filename (Check existence if necessary)"
}

# スクリプトとして直接実行された場合
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 4 ]; then
        error "Usage: $0 <model_dir> <filename> <model_id> <version_id>"
    fi
    civitai_download_unzip "$@"
fi
