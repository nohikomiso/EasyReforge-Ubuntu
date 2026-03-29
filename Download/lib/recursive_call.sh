#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

FAILED_SCRIPTS=()

handle_errors() {
    if [ "${#FAILED_SCRIPTS[@]}" -gt 0 ]; then
        log_error "Execution completed with errors in the following script(s):"
        for script in "${FAILED_SCRIPTS[@]}"; do
            log_error "  - $script"
        done
        return 1
    else
        log_info "All targeted scripts executed successfully."
        return 0
    fi
}

execute_script() {
    local script_file="$1"
    
    # 共通ヘルパー自身やライブラリ群は実行をスキップ
    if [[ "$script_file" == *"lib/"* ]] || \
       [[ "$(basename "$script_file")" == "common.sh" ]] || \
       [[ "$(basename "$script_file")" == "recursive_call.sh" ]]; then
        return 0
    fi

    log_info "Executing: $script_file"

    if is_dry_run; then
        log_info "[DRY-RUN] Would execute script: $script_file"
        return 0
    fi

    # サブスクリプトの失敗で親スクリプトが即座に死なないように、if内で実行しエラーコードを拾う
    if ! bash "$script_file"; then
        log_error "Script failed with error: $script_file"
        FAILED_SCRIPTS+=("$script_file")
    else
        log_info "Script finished successfully: $script_file"
    fi
}

find_and_execute() {
    local target="$1"
    
    if [ -f "$target" ]; then
        execute_script "$target" || true
    elif [ -d "$target" ]; then
        log_info "Scanning directory for .sh files: $target"
        
        # 安全なパス名のパースを行う
        local scripts=()
        while IFS=  read -r -d $'\0'; do
            scripts+=("$REPLY")
        done < <(find "$target" -type f -name "*.sh" -print0 | sort -z)

        if [ ${#scripts[@]} -eq 0 ]; then
            log_info "No .sh files found in directory: $target"
            return 0
        fi

        for script in "${scripts[@]}"; do
            execute_script "$script" || true
        done
    else
        log_error "Target not found: $target"
        FAILED_SCRIPTS+=("$target (Not Found)")
    fi
}

recursive_call() {
    for target in "$@"; do
        find_and_execute "$target"
    done
    handle_errors
}

# 単独で実行された場合
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -eq 0 ]; then
        error "Usage: $0 <dir_or_file1> [dir_or_file2 ...]"
    fi
    recursive_call "$@"
fi
