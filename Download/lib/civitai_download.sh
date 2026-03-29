#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

civitai_verify_api_key() {
    # .env ファイルなどから読み込むか環境変数に依存する
    # Civitaiの一部のNSFWや早期アクセスモデルはトークン必須だが基本は無くても動く
    if [ -z "${CIVITAI_API_TOKEN:-}" ]; then
        log_info "CIVITAI_API_TOKEN is not set. Some restricted models might fail to download."
        return 0
    fi
    log_info "Using Civitai API Token for authentication."
    return 0
}

civitai_get_download_url() {
    local version_id="$1"
    local url="https://civitai.com/api/v1/model-versions/${version_id}/download"
    
    # 認証トークンがある場合はクエリに付加（通信オプションにAuthorizationヘッダを付けるアプローチもあるがCivitai APIはURLパラメータ token= で受け付ける）
    if [ -n "${CIVITAI_API_TOKEN:-}" ]; then
        url="${url}?token=${CIVITAI_API_TOKEN}"
    fi
    echo "$url"
}

civitai_handle_rate_limit() {
    # 429 Too Many Requests に対する将来の拡張用フック
    # 現在は common.sh の download_with_retry によって単純な遅延リトライを適用している
    :
}

civitai_download() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"
    local version_id="$4"

    ensure_directory "$model_dir"

    local file_path="${model_dir}/${filename}"

    # Skip if already exists
    if [ -f "$file_path" ]; then
        log_info "Already exists: $file_path"
        return 0
    fi

    civitai_verify_api_key
    local url
    url=$(civitai_get_download_url "$version_id")

    log_info "Civitai Model ID: $model_id, Version ID: $version_id"
    download_with_retry "$url" "$file_path" 3
}

# もし単独で実行された場合は civitai_download を呼ぶ
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 4 ]; then
        error "Usage: $0 <model_dir> <filename> <model_id> <version_id>"
    fi
    civitai_download "$@"
fi
