#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

# URL構築
huggingface_get_download_url() {
    local model_id="$1"
    local filename="$2"
    # Hugging Faceの直接ダウンロード用URLフォーマット
    # 例: https://huggingface.co/Lykon/AnyLoRA/resolve/main/AnyLoRA_bakedVae_blessed_fp16.safetensors
    echo "https://huggingface.co/${model_id}/resolve/main/${filename}"
}

# Hub APIを利用したファイルリスティング
huggingface_list_files() {
    local model_id="$1"
    local url="https://huggingface.co/api/models/${model_id}"
    log_info "Fetching file list for ${model_id}..."
    
    local curl_opts=(-sS)
    if [ -n "${HF_TOKEN:-}" ]; then
        curl_opts+=(-H "Authorization: Bearer ${HF_TOKEN}")
    fi
    
    if is_dry_run; then
        log_info "[DRY-RUN] Would fetch model info from: $url"
        return 0
    fi
    
    curl "${curl_opts[@]}" "$url" || log_error "Failed to list files for $model_id"
}

# メインダウンロード関数
huggingface_download() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"

    ensure_directory "$model_dir"

    local file_path="${model_dir}/${filename}"

    if [ -f "$file_path" ]; then
        log_info "Already exists: $file_path"
        return 0
    fi

    local url
    url=$(huggingface_get_download_url "$model_id" "$filename")

    log_info "Hugging Face Repo: $model_id, File: $filename"
    
    # 秘密リポジトリ等で認証が必要な場合は HF_TOKEN を利用するが
    # 基本のダウンローダでは公開モデルを想定するため download_with_retry をそのまま利用
    # 将来的に認証が必要なケースが出た場合は common.sh 側にカスタムヘッダ拡張を入れる
    download_with_retry "$url" "$file_path" 3
}

# スクリプトとして直接実行された場合
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 3 ]; then
        error "Usage: $0 <model_dir> <filename> <model_id>"
    fi
    huggingface_download "$@"
fi
