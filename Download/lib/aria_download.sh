#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

curl_download() {
    local model_dir="$1"
    local filename="$2"
    local url="$3"
    
    local file_path="${model_dir}/${filename}"

    log_info "Falling back to curl via download_with_retry"
    download_with_retry "$url" "$file_path" 3
}

aria_download() {
    local model_dir="$1"
    local filename="$2"
    local url="$3"

    ensure_directory "$model_dir"

    local file_path="${model_dir}/${filename}"

    if [ -f "$file_path" ]; then
        log_info "Already exists: $file_path"
        return 0
    fi

    log_info "Downloading with aria2c: $url"

    if is_dry_run; then
        log_info "[DRY-RUN] Would run: aria2c --out=\"$filename\" --dir=\"$model_dir\" -x 4 -s 4 \"$url\""
        return 0
    fi

    local aria_success=0

    # aria2cコマンドが存在するか検証
    if command -v aria2c >/dev/null 2>&1; then
        # -x 4 : max connections per server
        # -s 4 : split connections
        # -c   : continue broken downloads
        if aria2c --out="$filename" --dir="$model_dir" \
            --max-connection-per-server=4 --split=4 \
            --auto-file-renaming=false -c --console-log-level=warn \
            "$url"; then
            
            if [ -f "$file_path" ]; then
                log_info "Successfully downloaded $filename using aria2c"
                aria_success=1
            else
                log_error "aria2c returned success but file not found at $file_path"
            fi
        else
            log_error "aria2c download failed with non-zero exit code."
        fi
    else
        log_info "aria2c is not installed in current environment."
    fi

    # フォールバック処理
    if [ $aria_success -eq 0 ]; then
        curl_download "$model_dir" "$filename" "$url"
    fi
}

# スクリプトとして直接実行された場合
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 3 ]; then
        error "Usage: $0 <model_dir> <filename> <direct_url>"
    fi
    aria_download "$@"
fi
