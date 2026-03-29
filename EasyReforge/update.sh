#!/bin/bash
# update.sh - EasyReforge Update Infrastructure
#
# Purpose: Update installed EasyReforge to latest version
# Functionality:
#   - Update EasyReforge repository to latest main branch
#   - Update EasyTools helper scripts
#   - Handle configuration migrations
#   - Reset styles.csv to defaults (user backups handled separately)
#
# Usage: bash update.sh
#
# Exit Codes:
#   0 - Success
#   1 - Failure

set -euo pipefail

# UTF-8 encoding for bilingual support
export LC_ALL=C.UTF-8

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helpers
if [[ -f "${SCRIPT_DIR}/src/lib/github.sh" ]]; then
    source "${SCRIPT_DIR}/src/lib/github.sh"
fi
if [[ -f "${SCRIPT_DIR}/src/lib/uv.sh" ]]; then
    source "${SCRIPT_DIR}/src/lib/uv.sh"
fi

# Configuration
# (For the main repo, we rely on the current git checkout to support forks)
# PROJECT_URL="https://github.com/Zuntan03/EasyReforge"
# PROJECT_BRANCH="main"
EASY_TOOLS_URL="https://github.com/Zuntan03/EasyTools"
EASY_TOOLS_BRANCH="main"

PROJECT_DIR="${SCRIPT_DIR}"
EASY_TOOLS_DIR="${SCRIPT_DIR}/EasyTools"
REFORGE_DIR="${SCRIPT_DIR}/Reforge"

##
# Helper Functions
##

die() {
    local msg_jp="$1"
    local msg_en="$2"
    local exit_code="${3:-1}"

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗" >&2
    echo "║ [エラー / ERROR]                                           ║" >&2
    echo "╠════════════════════════════════════════════════════════════╣" >&2
    echo "║ JP: $msg_jp" >&2
    echo "║ EN: $msg_en" >&2
    echo "╚════════════════════════════════════════════════════════════╝" >&2
    echo ""

    exit "$exit_code"
}

log_step() {
    local step_num="$1"
    local msg_jp="$2"
    local msg_en="$3"

    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "Step $step_num: $msg_en（ステップ$step_num: $msg_jp）"
    echo "─────────────────────────────────────────────────────────────"
}

log_success() {
    local msg_jp="$1"
    local msg_en="$2"

    echo "✓ $msg_en"
    echo "✓ $msg_jp"
}

##
# Step 1: Update EasyReforge repository
##
step_1_update_easyreforge() {
    log_step "1" "EasyReforgeリポジトリの更新" "Update EasyReforge Repository"

    # Verify git repo exists
    if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        die \
            "EasyReforgeがGitリポジトリ内にありません" \
            "EasyReforge is not inside a git repository" 1
    fi

    # フォークや別ブランチ運用を考慮し、現在のブランチをそのまま更新する
    local current_branch
    current_branch=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD)
    echo "現在のブランチ ($current_branch) を更新します / Updating current branch ($current_branch)..."

    # Fetch latest changes
    if ! git -C "$PROJECT_DIR" fetch origin; then
        die \
            "EasyReforgeをフェッチできません" \
            "Failed to fetch EasyReforge" 1
    fi

    # Pull latest changes (uses configured upstream for the current branch)
    if ! git -C "$PROJECT_DIR" pull origin "$current_branch"; then
        die \
            "EasyReforge ($current_branch) の更新に失敗しました" \
            "Failed to pull latest EasyReforge ($current_branch)" 1
    fi

    log_success "EasyReforgeが更新されました" "EasyReforge updated successfully"
}

##
# Step 2: Update EasyTools helper scripts
##
step_2_update_easytools() {
    log_step "2" "EasyToolsヘルパーの更新" "Update EasyTools Helper Scripts"

    # Check if EasyTools exists
    if [[ ! -d "${EASY_TOOLS_DIR}/.git" ]]; then
        echo "NOTE: EasyTools not found or not initialized"
        echo "メモ: EasyToolsが見つからないか初期化されていません"
        return 0
    fi

    # github_clone_or_pull を使用して安全にプル (関数が存在する場合)
    if type github_clone_or_pull &>/dev/null; then
        if ! github_clone_or_pull "${EASY_TOOLS_URL}.git" "${EASY_TOOLS_DIR}"; then
            echo "WARNING: Failed to update EasyTools (continuing anyway)" >&2
            echo "警告: EasyToolsの更新に失敗しました（続行します）" >&2
            return 0
        fi
        git -C "$EASY_TOOLS_DIR" checkout "$EASY_TOOLS_BRANCH" 2>/dev/null || true
    else
        # フォールバック (github_clone_or_pullがない場合)
        git -C "$EASY_TOOLS_DIR" fetch origin || return 0
        git -C "$EASY_TOOLS_DIR" checkout "$EASY_TOOLS_BRANCH" 2>/dev/null || true
        git -C "$EASY_TOOLS_DIR" pull origin "$EASY_TOOLS_BRANCH" || return 0
    fi

    log_success "EasyToolsが更新されました" "EasyTools updated successfully"
}

##
# Step 3: Handle configuration migrations
#
# This step runs reforge_update_config.py if it exists.
# This Python script handles backward-compatible config updates.
##
step_3_config_migration() {
    log_step "3" "設定のマイグレーション" "Configuration Migration"

    local config_script="${REFORGE_DIR}/src/reforge_update_config.py"
    local target_config="${REFORGE_DIR}/config.json"

    # Check if migration script exists
    if [[ ! -f "$config_script" ]]; then
        echo "NOTE: Configuration migration script not found (first install or Phase 2 pending)"
        echo "メモ: 設定マイグレーションスクリプトが見つかりません（初回インストールまたはPhase 2待機中）"
        return 0
    fi

    # uv パラダイムで Python スクリプトを実行する
    local python_cmd="python3"
    if command -v uv &> /dev/null; then
        # 仮想環境があれば指定して uv run を使用
        if [[ -d "${SCRIPT_DIR}/src/venv" ]]; then
            export VIRTUAL_ENV="${SCRIPT_DIR}/src/venv"
        elif [[ -d "${SCRIPT_DIR}/src/.venv" ]]; then
            export VIRTUAL_ENV="${SCRIPT_DIR}/src/.venv"
        fi
        python_cmd="uv run python"
    fi

    if ! $python_cmd "$config_script" "$target_config"; then
        echo "WARNING: Configuration migration failed (continuing anyway)" >&2
        echo "警告: 設定マイグレーションに失敗しました（続行します）" >&2
        return 0
    fi

    log_success "設定がマイグレーションされました" "Configuration migrated successfully"
}

##
# Step 4: Reset styles.csv to defaults
#
# Note from Phase 0 analysis:
# - Update.sh overwrites styles.csv with default version
# - Users should back up manual edits; backups created with timestamps
# - Migration handled in reforge_update_ui-config.py
##
step_4_reset_styles() {
    log_step "4" "UIスタイルのリセット" "Reset UI Styles"

    local styles_file="${REFORGE_DIR}/src/styles.csv"
    local backup_file
    backup_file="${REFORGE_DIR}/src/styles.csv.backup.$(date +%Y%m%d_%H%M%S)"

    # Skip if no styles.csv exists
    if [[ ! -f "$styles_file" ]]; then
        echo "NOTE: styles.csv not found (first install or Phase 2 pending)"
        echo "メモ: styles.csv が見つかりません（初回インストールまたはPhase 2待機中）"
        return 0
    fi

    # Create backup with timestamp
    if cp "$styles_file" "$backup_file"; then
        echo "Backed up styles.csv to: $backup_file"
        echo "styles.csv をバックアップしました: $backup_file"
    fi

    # Reset styles.csv to defaults from repository
    # (This will be handled by git in the repo)
    if git -C "$PROJECT_DIR" checkout HEAD -- "Reforge/src/styles.csv" 2> /dev/null; then
        log_success "スタイルがリセットされました" "Styles reset to defaults"
    else
        echo "NOTE: Could not reset styles.csv (may not exist in repo yet)"
        echo "メモ: styles.csv をリセットできません（リポジトリにまだ存在しない可能性）"
        return 0
    fi
}

##
# Main orchestration
##
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║          EasyReforge Update Utility                       ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute update steps
    step_1_update_easyreforge
    step_2_update_easytools
    step_3_config_migration
    step_4_reset_styles

    # Success
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║      更新が完了しました！                                ║"
    echo "║      Update Complete!                                    ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    return 0
}

# Execute main
main "$@"
exit $?
