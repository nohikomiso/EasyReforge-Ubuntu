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

# Configuration
PROJECT_URL="https://github.com/Zuntan03/EasyReforge"
PROJECT_BRANCH="main"
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
    if [[ ! -d "${PROJECT_DIR}/.git" ]]; then
        die \
            "EasyReforgeがGitリポジトリではありません" \
            "EasyReforge is not a git repository" 1
    fi

    # Fetch latest changes
    if ! git -C "$PROJECT_DIR" fetch origin; then
        die \
            "EasyReforgeをフェッチできません" \
            "Failed to fetch EasyReforge" 1
    fi

    # Switch/checkout to main branch
    if ! git -C "$PROJECT_DIR" switch "$PROJECT_BRANCH" 2> /dev/null; then
        if ! git -C "$PROJECT_DIR" checkout "$PROJECT_BRANCH" 2> /dev/null; then
            die \
                "メインブランチに切り替えられません" \
                "Failed to switch to main branch" 1
        fi
    fi

    # Pull latest changes
    if ! git -C "$PROJECT_DIR" pull origin "$PROJECT_BRANCH"; then
        die \
            "EasyReforgeの更新に失敗しました" \
            "Failed to pull latest EasyReforge" 1
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

    # Fetch latest changes
    if ! git -C "$EASY_TOOLS_DIR" fetch origin; then
        echo "WARNING: Failed to fetch EasyTools (continuing anyway)" >&2
        echo "警告: EasyToolsのフェッチに失敗しました（続行します）" >&2
        return 0
    fi

    # Switch/checkout to branch
    if ! git -C "$EASY_TOOLS_DIR" switch "$EASY_TOOLS_BRANCH" 2> /dev/null; then
        if ! git -C "$EASY_TOOLS_DIR" checkout "$EASY_TOOLS_BRANCH" 2> /dev/null; then
            echo "WARNING: Failed to switch EasyTools branch (continuing anyway)" >&2
            echo "警告: EasyToolsブランチ切り替えに失敗しました（続行します）" >&2
            return 0
        fi
    fi

    # Pull latest changes
    if ! git -C "$EASY_TOOLS_DIR" pull origin "$EASY_TOOLS_BRANCH"; then
        echo "WARNING: Failed to pull latest EasyTools (continuing anyway)" >&2
        echo "警告: EasyToolsの更新に失敗しました（続行します）" >&2
        return 0
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

    # Check if migration script exists
    if [[ ! -f "$config_script" ]]; then
        echo "NOTE: Configuration migration script not found (first install or Phase 2 pending)"
        echo "メモ: 設定マイグレーションスクリプトが見つかりません（初回インストールまたはPhase 2待機中）"
        return 0
    fi

    # Check if Python venv is activated (optional)
    # If not activated, we'll use system python3
    if ! python3 "$config_script"; then
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
    local backup_file="${REFORGE_DIR}/src/styles.csv.backup.$(date +%Y%m%d_%H%M%S)"

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
