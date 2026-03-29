#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# EasyReforge LLM Inference Base (Linux)
# This library provides core functionality for model downloading and launching llama-server.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EASY_TOOLS="${SCRIPT_DIR}/../EasyTools"
ARIA_HELPER="${SCRIPT_DIR}/../../Download/lib/aria_download.sh"

# Global defaults
LLM_HOST="${LLM_HOST:-localhost}"
LLM_PORT="${LLM_PORT:-7830}"

log_info() { echo -e "\e[32m[INFO] $*\e[0m"; }
log_error() { echo -e "\e[31m[ERROR] $*\e[0m" >&2; }

# Download model if it doesn't exist
# Usage: download_model REPO FILE [SUBDIR]
download_model() {
    local repo="$1"
    local filename="$2"
    local subdir="${3:-}"
    local dest_dir="${SCRIPT_DIR}/models"

    mkdir -p "$dest_dir"

    if [ -f "${dest_dir}/${filename}" ]; then
        log_info "Model already exists: ${filename}"
        return 0
    fi

    log_info "Downloading model: ${filename} from ${repo}"
    
    local url="https://huggingface.co/${repo}/resolve/main/${subdir}${filename}"
    
    # Use aria2c directly or through helper if it exists
    if [ -f "$ARIA_HELPER" ]; then
        bash "$ARIA_HELPER" "$dest_dir" "$filename" "$url"
    else
        log_info "Using system aria2c (fallback)..."
        aria2c -x 16 -s 16 -d "$dest_dir" -o "$filename" "$url"
    fi
}

# Launch llama-server
# Usage: launch_server MODEL_FILE [EXTRA_ARGS...]
launch_server() {
    local model_file="$1"
    shift
    
    local model_path="${SCRIPT_DIR}/models/${model_file}"
    if [ ! -f "$model_path" ]; then
        # Check absolute path if not in models dir
        if [ -f "$model_file" ]; then
            model_path="$model_file"
        else
            log_error "Model file not found: $model_file"
            exit 1
        fi
    fi

    local bin="llama-server"
    
    # Search for llama-server binary in common locations
    if ! command -v "$bin" &> /dev/null; then
        # Try local build directory (EasyTools structure)
        if [ -f "${EASY_TOOLS}/LlamaCpp/LlamaCpp/llama-server" ]; then
            bin="${EASY_TOOLS}/LlamaCpp/LlamaCpp/llama-server"
        else
            log_error "llama-server not found in PATH or ${EASY_TOOLS}/LlamaCpp/LlamaCpp/."
            log_error "Please install llama.cpp or build it inside ${EASY_TOOLS}/LlamaCpp/."
            exit 1
        fi
    fi

    log_info "Starting LLM Server on http://${LLM_HOST}:${LLM_PORT}"
    log_info "Model: ${model_path}"
    
    # Automaticaly open browser if interactive
    if [[ -t 0 && "${OPEN_BROWSER:-1}" == "1" ]]; then
        ( sleep 2; xdg-open "http://${LLM_HOST}:${LLM_PORT}" 2>/dev/null || true ) &
    fi

    # Execute server
    "$bin" \
        --host "$LLM_HOST" \
        --port "$LLM_PORT" \
        --model "$model_path" \
        "$@"
}

# For sourcing only
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # When executed directly, show help
    echo "This script is a library and should be sourced by other scripts."
    exit 0
fi
