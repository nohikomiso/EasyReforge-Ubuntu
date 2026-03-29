#!/bin/bash
# common.sh - Shared utilities for all download scripts

# Logging utilities
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $*"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

log_warn() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $*"
}

error() {
    log_error "$@"
    exit 1
}

# Directory management
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir" || error "Failed to create directory: $dir"
    fi
}

# Get script directory of the calling script
get_script_dir() {
    # BASH_SOURCE[1] is the script that sourced this file
    local caller_script="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
    if [ -n "$caller_script" ]; then
        cd "$(dirname "$caller_script")" && pwd
    fi
}

# Dry-run mode
is_dry_run() {
    [ "${DRY_RUN:-0}" = "1" ]
}

# Validate URL format
validate_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?:// ]]; then
        error "Invalid URL format (must start with http:// or https://): $url"
    fi
}

# Extract filename from URL
extract_filename_from_url() {
    local url="$1"
    local filename
    # Strip URL parameters
    local path="${url%%\?*}"
    filename=$(basename "$path")
    
    if [ -z "$filename" ] || [ "$filename" = "/" ]; then
        error "Could not extract filename from URL: $url"
    fi
    echo "$filename"
}

# Validate file integrity (size > 0 for now)
validate_file_integrity() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        error "File does not exist: $file_path"
    fi
    
    local file_size
    file_size=$(stat -c%s "$file_path" 2>/dev/null || wc -c < "$file_path")
    if [ "$file_size" -eq 0 ]; then
        error "File size is 0 bytes, download may have failed: $file_path"
    fi
    return 0
}

# Download with retry mechanism
download_with_retry() {
    local url="$1"
    local dest="$2"
    local max_retries="${3:-3}"
    local attempt=1
    local success=0

    validate_url "$url"
    
    # --- SMART SEARCH: カテゴリ配下を再帰的に探す ---
    local dest_dir="$(dirname "$dest")"
    
    # 1. 既定の場所に直接あるか？
    if [ -e "$dest" ]; then
        log_info "Skipping download: File already exists at $dest"
        return 0
    fi
    
    # 2. サブディレクトリ内に潜んでいないか？ (find による再帰探索)
    local fname="$(basename "$dest")"
    local search_root="$dest_dir"
    # 近接する親ディレクトリ (Stable-diffusion/ 等) から探索を開始
    # ※ models/ フォルダなど広範囲すぎる場所への波及を防ぐため dirname で制御
    if [[ "$dest_dir" == *"/"* ]] && [[ "$dest_dir" != *"/models" ]]; then
        search_root="$(dirname "$dest_dir")"
    fi

    log_info "Checking subdirectories in '$search_root' for '$fname'..."
    local found_file
    found_file=$(find "$search_root" -maxdepth 3 -name "$fname" -type f -print -quit 2>/dev/null || true)
    
    if [ -n "$found_file" ]; then
        log_info "Skipping download: Found existing file in subdirectory: $found_file"
        return 0
    fi
    
    if is_dry_run; then
        log_info "[DRY-RUN] Would download: $url -> $dest"
        return 0
    fi

    local curl_opts=(-L -sS)
    
    while [ $attempt -le "$max_retries" ]; do
        log_info "Downloading (Attempt $attempt/$max_retries): $url"
        
        local tmp_dest="${dest}.tmp.$$"
        
        if curl "${curl_opts[@]}" -o "$tmp_dest" "$url"; then
            if validate_file_integrity "$tmp_dest"; then
                mv "$tmp_dest" "$dest"
                success=1
                break
            fi
        fi
        
        log_error "Download attempt $attempt failed."
        [ -f "$tmp_dest" ] && rm -f "$tmp_dest"
        
        attempt=$((attempt + 1))
        [ $attempt -le "$max_retries" ] && sleep 2
    done

    if [ $success -eq 0 ]; then
        error "Failed to download $url after $max_retries attempts"
    fi
    
    log_info "Download complete: $dest"
}
