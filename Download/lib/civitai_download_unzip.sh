#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/civitai_download.sh"

civitai_download_unzip() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"
    local version_id="$4"

    ensure_directory "$model_dir"

    # 解凍後の代表ファイル（バッチ内で指定された検証用ファイル）が存在するかチェック
    local target_file="${model_dir}/${filename}"
    if [ -f "$target_file" ]; then
        log_info "Already unzipped and target exists: $target_file"
        return 0
    fi

    # ダウンロード用の一時ファイル名
    local zip_filename="temp_civitai_${model_id}_${version_id}.zip"
    local zip_path="${model_dir}/${zip_filename}"

    log_info "Downloading ZIP archive from Civitai (Model: $model_id, Version: $version_id)"
    
    # civitai_download 関数を利用して ZIP をダウンロード
    civitai_download "$model_dir" "$zip_filename" "$model_id" "$version_id"
    
    if ! command -v unzip >/dev/null 2>&1; then
        error "'unzip' command is required but not installed."
    fi

    if is_dry_run; then
        log_info "[DRY-RUN] Would extract $zip_path to $model_dir and delete archive"
        return 0
    fi

    log_info "Extracting $zip_path to $model_dir"
    
    # -o : overwrite existing files without prompting
    # -q : quiet mode
    if unzip -o -q "$zip_path" -d "$model_dir"; then
        log_info "Extraction successful. Cleaning up: $zip_path"
        rm -f "$zip_path"
    else
        local exit_code=$?
        error "Extraction failed for $zip_path with error code $exit_code."
    fi
    
    # 解凍後に指定されたターゲットファイルが存在するか一応確認 (任意だが堅牢性向上のため)
    if [ ! -f "$target_file" ]; then
        log_error "Warning: Specified target file '$target_file' was not found after extraction."
    fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 4 ]; then
        error "Usage: $0 <model_dir> <target_filename_after_unzip> <model_id> <version_id>"
    fi
    civitai_download_unzip "$@"
fi
