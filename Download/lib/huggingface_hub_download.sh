#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/huggingface_download.sh"

# huggingface_hub_download
# huggingface-cli を利用したダウンロードを行い、失敗時や未インストール時は
# curlベースの huggingface_download へフォールバックする
huggingface_hub_download() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"

    ensure_directory "$model_dir"

    local file_path="${model_dir}/${filename}"

    if [ -f "$file_path" ]; then
        log_info "Already exists: $file_path"
        return 0
    fi

    log_info "Attempting to download using huggingface-cli (Repo: $model_id, File: $filename)"

    if is_dry_run; then
        log_info "[DRY-RUN] Would run: huggingface-cli download \"$model_id\" \"$filename\" --local-dir \"$model_dir\""
        return 0
    fi

    local cli_success=0

    # huggingface-cli コマンドが存在するか確認
    if command -v huggingface-cli >/dev/null 2>&1; then
        # huggingface-cli の --local-dir はシンボリックリンクベースの場合があるが
        # --local-dir-use-symlinks False で実ファイルを配置させる
        if huggingface-cli download "$model_id" "$filename" --local-dir "$model_dir" --local-dir-use-symlinks False; then
            if [ -f "$file_path" ]; then
                log_info "Successfully downloaded $filename using huggingface-cli"
                cli_success=1
            else
                log_error "huggingface-cli succeeded but file not found at $file_path"
            fi
        else
            log_error "huggingface-cli download failed with non-zero exit code."
        fi
    else
        log_info "huggingface-cli not found in current environment."
    fi

    # フォールバックとして通常の直接ダウンロードを実施
    if [ $cli_success -eq 0 ]; then
        log_info "Falling back to direct URL download via curl."
        huggingface_download "$model_dir" "$filename" "$model_id"
    fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 3 ]; then
        error "Usage: $0 <model_dir> <filename> <model_id>"
    fi
    huggingface_hub_download "$@"
fi
