#!/bin/bash
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

    # Python 正規版ダウンローダーの呼び出し (正式な API トークンを利用)
    # .venv がルートにあることを想定
    local project_root
    project_root="$(cd "${SCRIPT_DIR}/../.." && pwd)"

    if [ -x "${project_root}/.venv/bin/python3" ]; then
        cd "${project_root}"
        uv run python3 "${SCRIPT_DIR}/civitai_download.py" "$version_id" "$model_dir" "$filename"
    else
        # フォールバック: 標準の curl 方式 (WAFブロックに弱い可能性あり)
        log_warn "Python env not found. Falling back to curl method."
        local token_suffix=""
        if [ -n "${CIVITAI_API_TOKEN:-}" ]; then
            token_suffix="?token=${CIVITAI_API_TOKEN}"
        fi
        local url="https://civitai.com/api/v1/model-versions/${version_id}/download${token_suffix}"
        download_with_retry "$url" "${model_dir}/${filename}" 3
    fi
}

# スクリプトとして直接実行された場合
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 4 ]; then
        error "Usage: $0 <model_dir> <filename> <model_id> <version_id>"
    fi
    civitai_download "$@"
fi
