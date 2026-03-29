#!/bin/bash
# easyreforge_installer.sh - EasyReforge Ubuntu Bootstrap Installer
#
# Purpose: One-command entry point for installing EasyReforge on Ubuntu
# Implements Phase 0 analysis: 10-step bootstrap flow
# Reference: docs/01_analysis_summary.md (Phase 0 analysis)
#
# Usage:
#   bash easyreforge_installer.sh
#   curl -fsSL https://raw.githubusercontent.com/.../easyreforge_installer.sh | bash
#
# Exit Codes:
#   0 - Success (installation complete)
#   1 - Failure (prerequisites, path validation, conflicts, repo init, setup call)

set -euo pipefail

# UTF-8 encoding for bilingual (Japanese/English) support
export LC_ALL=C.UTF-8

##
# Configuration (from Phase 0 analysis)
##
# readonly PROJECT_NAME="EasyReforge" # unused in bootstrap
readonly PROJECT_URL="https://github.com/Zuntan03/EasyReforge"
readonly PROJECT_BRANCH="main"
readonly EASY_TOOLS_URL="https://github.com/Zuntan03/EasyTools"
readonly EASY_TOOLS_BRANCH="main"

# Minimum version requirements
readonly MIN_BASH_VERSION="4"
readonly MIN_GIT_VERSION="2.25"
# Python will be managed by uv
# readonly MIN_DISK_SPACE_MB="51200"  # Checked in reforge.sh

# Get absolute script directory (handles pipe execution via mktemp)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helpers
if [[ -f "${SCRIPT_DIR}/src/lib/github.sh" ]]; then
    source "${SCRIPT_DIR}/src/lib/github.sh"
else
    # First time clone behavior fallback (if script is piped)
    github_clone_or_pull() {
        local url="$1"
        local tgt="$2"
        git clone "$url" "$tgt" || return 1
    }
fi
if [[ -f "${SCRIPT_DIR}/src/lib/uv.sh" ]]; then
    source "${SCRIPT_DIR}/src/lib/uv.sh"
fi

# Derived paths (from Phase 0 variable mapping)
PROJECT_DIR="${SCRIPT_DIR}"
EASY_TOOLS_DIR="${SCRIPT_DIR}/EasyTools"
SETUP_SH="${SCRIPT_DIR}/setup.sh"
DOWNLOAD_SCRIPT="${SCRIPT_DIR}/../Download/NoobAiEpsilonPred_Minimum.sh"

# User choice for model download
DOWNLOAD_YES_OR_NO=""

##
# Helper Functions
##

##
# die - Exit with bilingual error message
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

##
# log_step - Print step header
##
log_step() {
    local step_num="$1"
    local msg_jp="$2"
    local msg_en="$3"

    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo "Step $step_num: $msg_en（ステップ$step_num: $msg_jp）"
    echo "─────────────────────────────────────────────────────────────"
}

##
# log_success - Print success message
##
log_success() {
    local msg_jp="$1"
    local msg_en="$2"

    echo "✓ $msg_en"
    echo "✓ $msg_jp"
}

##
# check_requirement - Verify tool availability and optionally check version
#
# Arguments:
#   $1 - Command name (e.g., "git", "bash", "python3")
#   $2 - Minimum version requirement (optional, e.g., "2.25")
#
# Returns:
#   0 if available and meets version requirement
#   1 if missing or version insufficient
##
check_requirement() {
    local cmd="$1"
    local min_version="${2:-}"
    local actual_version

    # Check if command exists
    if ! command -v "$cmd" &> /dev/null; then
        return 1
    fi

    # If no version requirement specified, we're done
    [[ -z "$min_version" ]] && return 0

    # Get version and compare
    case "$cmd" in
        bash)
            actual_version="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
            if [[ "${BASH_VERSINFO[0]}" -lt "${min_version%.*}" ]]; then
                return 1
            fi
            ;;
        git)
            actual_version=$(git --version | awk '{print $3}')
            if [[ "$actual_version" < "$min_version" ]]; then
                return 1
            fi
            ;;
        uv)
            # Just test if command exists
            if ! command -v uv &> /dev/null; then
                return 1
            fi
            ;;
        *)
            # Version check not implemented for this command
            return 0
            ;;
    esac

    return 0
}

##
# Step 1: Setup environment
##
step_1_setup_environment() {
    log_step "1" "環境のセットアップ" "Environment Setup"

    # UTF-8 is already set at script start
    # Verify locale is correct
    if [[ "${LC_ALL:-}" != "C.UTF-8" ]] && [[ "${LANG:-}" != *"UTF-8"* ]]; then
        echo "WARNING: UTF-8 locale not fully configured" >&2
    fi

    log_success "環境変数が設定されました" "Environment variables initialized"
}

##
# Step 2: Validate prerequisites
##
step_2_validate_prerequisites() {
    log_step "2" "前提条件の検証" "Prerequisites Validation"

    # Check bash version
    if ! check_requirement bash "$MIN_BASH_VERSION"; then
        die \
            "bash ${MIN_BASH_VERSION} 以上が必要です" \
            "bash ${MIN_BASH_VERSION}+ required" 1
    fi
    log_success "bash が見つかりました" "bash found"

    # Check git availability
    if ! check_requirement git "$MIN_GIT_VERSION"; then
        die \
            "git ${MIN_GIT_VERSION} 以上が必要です。\`sudo apt install git\` を実行してください" \
            "git ${MIN_GIT_VERSION}+ required. Run \`sudo apt install git\`" 1
    fi
    log_success "git が見つかりました" "git found"

    # Check curl availability
    if ! check_requirement curl; then
        die \
            "curl が見つかりません。\`sudo apt install curl\` を実行してください" \
            "curl not found. Run \`sudo apt install curl\`" 1
    fi
    log_success "curl が見つかりました" "curl found"

    # Check uv availability
    if ! check_requirement uv; then
        die \
            "uv が見つかりません。\`curl -LsSf https://astral.sh/uv/install.sh | sh\` を実行してインストールし、シェルを再起動してください。" \
            "uv not found. Run \`curl -LsSf https://astral.sh/uv/install.sh | sh\` to install, then restart shell." 1
    fi
    log_success "uv が見つかりました" "uv found"
}

##
# Step 3: Validate installation path
##
step_3_validate_path() {
    log_step "3" "インストールパスの検証" "Installation Path Validation"

    # Regex pattern: allow alphanumeric, colon, forward slash, hyphen, underscore
    # Reject: spaces, special characters, non-ASCII
    if [[ ! "$SCRIPT_DIR" =~ ^[a-zA-Z0-9:/_-]+$ ]]; then
        die \
            "インストールパスに無効な文字が含まれています。\n英数字、スラッシュ、ハイフン、アンダースコアのみ使用できます。\nスペースや日本語文字は使用できません。\n\n現在のパス: $SCRIPT_DIR" \
            "Invalid characters in installation path.\nOnly alphanumeric, /, -, and _ are allowed.\nSpaces and special characters are not permitted.\n\nCurrent path: $SCRIPT_DIR" 1
    fi

    log_success "パスが有効です: $SCRIPT_DIR" "Path is valid: $SCRIPT_DIR"
}

##
# Step 4: Check for conflicting WebUI installations
##
step_4_check_conflicts() {
    log_step "4" "既存WebUIの競合チェック" "Conflict Detection"

    local conflict_found=0
    local conflict_msg_jp=""
    local conflict_msg_en=""

    # Check for A1111 (Automatic1111)
    if [[ -d "${SCRIPT_DIR}/../stable-diffusion-webui-master" ]] || \
       [[ -d "${SCRIPT_DIR}/../automatic1111" ]]; then
        conflict_msg_jp+="- Automatic1111 WebUI が見つかりました\n"
        conflict_msg_en+="- Automatic1111 WebUI detected\n"
        conflict_found=1
    fi

    # Check for Forge
    if [[ -d "${SCRIPT_DIR}/../stable-diffusion-webui-forge" ]] || \
       [[ -d "${SCRIPT_DIR}/../forge" ]]; then
        conflict_msg_jp+="- Forge WebUI が見つかりました\n"
        conflict_msg_en+="- Forge WebUI detected\n"
        conflict_found=1
    fi

    # Check for reForge (self)
    if [[ -d "${SCRIPT_DIR}/../stable-diffusion-webui-reForge" ]] && \
       [[ "$SCRIPT_DIR" != */EasyReforge ]]; then
        conflict_msg_jp+="- reForge WebUI (別のインストール) が見つかりました\n"
        conflict_msg_en+="- reForge WebUI (different installation) detected\n"
        conflict_found=1
    fi

    if [[ $conflict_found -eq 1 ]]; then
        die \
            "競合するWebUIが見つかりました。\n別のディレクトリにインストールしてください。\n\n$conflict_msg_jp" \
            "Conflicting WebUI installation detected.\nPlease install in a different directory.\n\n$conflict_msg_en" 1
    fi

    log_success "競合なし" "No conflicts detected"
}

##
# Step 5: Check Git availability (system git only on Linux)
##
step_5_check_git() {
    log_step "5" "Git環境の確認" "Git Environment Check"

    # Git is already checked in step 2, just confirm it's in PATH
    if ! command -v git &> /dev/null; then
        die \
            "git が PATH に見つかりません。インストール後、シェルを再起動してください。" \
            "git not found in PATH. Please restart your shell after installation." 1
    fi

    local git_version
    git_version=$(git --version | awk '{print $3}')
    log_success "git バージョン: $git_version" "git version: $git_version"
}

##
# Step 6: Initialize EasyTools repository
##
step_6_init_easytools() {
    log_step "6" "EasyToolsリポジトリの初期化" "EasyTools Repository Initialization"

    if ! github_clone_or_pull "${EASY_TOOLS_URL}.git" "$EASY_TOOLS_DIR"; then
        die \
            "EasyToolsリポジトリの初期化に失敗しました。ネットワーク接続を確認してください。" \
            "Failed to initialize EasyTools repository. Check network connection." 1
    fi
    git -C "$EASY_TOOLS_DIR" checkout "$EASY_TOOLS_BRANCH" 2>/dev/null || true

    log_success "EasyToolsが初期化されました: $EASY_TOOLS_DIR" "EasyTools initialized: $EASY_TOOLS_DIR"
}

##
# Step 7: Initialize EasyReforge repository
##
step_7_init_easyreforge() {
    log_step "7" "EasyReforgeリポジトリの初期化" "EasyReforge Repository Initialization"

    if ! github_clone_or_pull "${PROJECT_URL}.git" "$PROJECT_DIR"; then
        die \
            "EasyReforgeリポジトリの初期化に失敗しました。ネットワーク接続を確認してください。" \
            "Failed to initialize EasyReforge repository. Check network connection." 1
    fi
    git -C "$PROJECT_DIR" checkout "$PROJECT_BRANCH" 2>/dev/null || true

    log_success "EasyReforgeが初期化されました: $PROJECT_DIR" "EasyReforge initialized: $PROJECT_DIR"
}

##
# Step 8: Call main setup orchestrator
##
step_8_run_setup() {
    log_step "8" "セットアップスクリプトの実行" "Running Main Setup"

    if [[ ! -f "$SETUP_SH" ]]; then
        # If setup.sh doesn't exist yet, this is expected in early Phase 1
        # In later phases, setup.sh should exist
        echo "Note: setup.sh not yet created (expected in Phase 2+)"
        return 0
    fi

    if ! bash "$SETUP_SH"; then
        die \
            "セットアップスクリプトの実行に失敗しました。" \
            "Setup script failed." 1
    fi

    log_success "セットアップが完了しました" "Setup completed successfully"
}

##
# Step 9: Optional model downloads
##
step_9_download_models() {
    log_step "9" "モデルダウンロード（オプション）" "Optional Model Downloads"

    # Skip if user said 'n'
    if [[ "${DOWNLOAD_YES_OR_NO:-}" == "n" ]]; then
        echo "Skipping model downloads (user choice)"
        echo "モデルダウンロードをスキップします（ユーザー選択）"
        return 0
    fi

    # Check if download script exists
    if [[ ! -f "$DOWNLOAD_SCRIPT" ]]; then
        echo "Note: Model download script not yet created (expected in Phase 4+)"
        echo "メモ: モデルダウンロードスクリプトはまだ作成されていません（Phase 4+で作成予定）"
        return 0
    fi

    # Attempt download (errors ignored per Phase 0 analysis line 114)
    if ! bash "$DOWNLOAD_SCRIPT"; then
        echo "WARNING: Model download failed (continuing anyway)" >&2
        echo "警告: モデルダウンロードに失敗しました（続行します）" >&2
        return 0  # Don't fail the installer
    fi

    log_success "モデルをダウンロードしました" "Models downloaded successfully"
}

##
# Step 10: Finalize and exit
##
step_10_finalize() {
    log_step "10" "セットアップ完了" "Setup Complete"

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║  インストール完了！ / Installation Complete!              ║"
    echo "║                                                            ║"
    echo "║  次のステップ / Next Steps:                               ║"
    echo "║  1. cd $PROJECT_DIR"
    echo "║  2. bash EasyReforge/setup.sh                             ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# Removed init_repository in favor of github.sh helper functions.

##
# prompt_for_model_download - Ask user if they want to download models
##
prompt_for_model_download() {
    log_step "0" "モデルダウンロード確認" "Model Download Confirmation"

    local prompt_jp="必要なモデルなどをダウンロードしますか？ [y/n]（空欄なら y）"
    local prompt_en="Download required models? [y/n] (default: y)"

    # Check if TTY is available (interactive terminal)
    if [[ ! -t 0 ]]; then
        # Non-interactive mode (pipe): default to yes
        echo "Non-interactive mode detected. Defaulting to download."
        DOWNLOAD_YES_OR_NO="y"
        return 0
    fi

    # Interactive mode: prompt user
    echo ""
    echo "$prompt_jp"
    echo "$prompt_en"
    read -r -p "Your choice: " DOWNLOAD_YES_OR_NO || DOWNLOAD_YES_OR_NO=""

    # Empty input defaults to yes
    DOWNLOAD_YES_OR_NO="${DOWNLOAD_YES_OR_NO:-y}"
}

##
# main - Orchestrate all installation steps
##
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║         EasyReforge Ubuntu Bootstrap Installer            ║"
    echo "║                 Installing to: $SCRIPT_DIR                   ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute 10-step flow from Phase 0 analysis
    step_1_setup_environment
    step_2_validate_prerequisites
    step_3_validate_path
    step_4_check_conflicts
    step_5_check_git
    step_6_init_easytools
    step_7_init_easyreforge

    # Ask about model downloads before running setup
    prompt_for_model_download

    step_8_run_setup
    step_9_download_models
    step_10_finalize

    return 0
}

# Execute main function
main "$@"
exit $?
