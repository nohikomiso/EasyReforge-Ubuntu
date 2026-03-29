#!/bin/bash
# setup.sh - EasyReforge Main Setup Orchestrator
#
# Purpose: Main orchestration script that coordinates installation steps
# Called from: easyreforge_installer.sh
# Calls: Reforge/reforge.sh, Reforge/reforge_extension.sh, Reforge/reforge_link.sh
#
# Usage: bash setup.sh
#
# Exit Codes:
#   0 - Success
#   1 - Failure in any phase

set -euo pipefail

# UTF-8 encoding for bilingual support
export LC_ALL=C.UTF-8

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration (can be overridden by environment variables from parent installer)
PROJECT_NAME="${PROJECT_NAME:-EasyReforge}"
REFORGE_DIR="${SCRIPT_DIR}/Reforge"
export CIVITAI_API_TOKEN="${CIVITAI_API_TOKEN:-}"

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

log_phase() {
    local phase_num="$1"
    local msg_jp="$2"
    local msg_en="$3"

    echo ""
    echo "═════════════════════════════════════════════════════════════"
    echo "Phase $phase_num: $msg_en（フェーズ$phase_num: $msg_jp）"
    echo "═════════════════════════════════════════════════════════════"
}

log_success() {
    local msg_jp="$1"
    local msg_en="$2"

    echo "✓ $msg_en"
    echo "✓ $msg_jp"
}

##
# Phase 1: Setup reForge environment (PyTorch, venv, dependencies)
#
# This phase requires the most careful implementation:
# - Detect NVIDIA GPU with nvidia-smi
# - Install PyTorch with correct CUDA wheel
# - Create Python venv and activate it
# - Install requirements.txt (198 packages)
#
# Note: In Phase 1, this is stubbed. Phase 2 will implement full reforge.sh
##
phase_1_reforge_environment() {
    log_phase "1" "reForge環境のセットアップ" "reForge Environment Setup"

    # Check if reforge.sh exists (should be created in Phase 2)
    if [[ ! -f "${REFORGE_DIR}/reforge.sh" ]]; then
        echo "Note: reforge.sh not yet created (will be implemented in Phase 2)"
        echo "メモ: reforge.sh はまだ作成されていません（Phase 2で実装予定）"
        log_success "フェーズ1スキップ" "Phase 1 skipped (Phase 2 pending)"
        return 0
    fi

    # Call reforge.sh if it exists
    if ! bash "${REFORGE_DIR}/reforge.sh"; then
        die \
            "reForge環境のセットアップに失敗しました" \
            "Failed to setup reForge environment" 1
    fi

    log_success "reForge環境がセットアップされました" "reForge environment setup complete"
}

##
# Phase 2: Install reForge extensions (13 GitHub extensions)
#
# This phase:
# - Clones 13 verified GitHub extensions
# - Checks out to specific commits for reproducibility
# - Backs up unsupported extensions with timestamp
#
# Note: In Phase 1, this is stubbed. Phase 2 will implement full reforge_extension.sh
##
phase_2_reforge_extensions() {
    log_phase "2" "reForge拡張機能のインストール" "reForge Extensions Installation"

    # Check if reforge_extension.sh exists (should be created in Phase 2)
    if [[ ! -f "${REFORGE_DIR}/reforge_extension.sh" ]]; then
        echo "Note: reforge_extension.sh not yet created (will be implemented in Phase 2)"
        echo "メモ: reforge_extension.sh はまだ作成されていません（Phase 2で実装予定）"
        log_success "フェーズ2スキップ" "Phase 2 skipped (Phase 2 pending)"
        return 0
    fi

    # Call reforge_extension.sh if it exists
    if ! bash "${REFORGE_DIR}/reforge_extension.sh"; then
        die \
            "拡張機能のインストールに失敗しました" \
            "Failed to install extensions" 1
    fi

    log_success "拡張機能がインストールされました" "Extensions installed successfully"
}

##
# Phase 3: Create model symlinks (link directories to external sources)
#
# This phase:
# - Creates Linux native symlinks (ln -s) to replace Windows junctions
# - Links Model/Stable-diffusion/*, Model/Lora/*, etc.
# - Supports both internal and external model directories
#
# Note: In Phase 1, this is stubbed. Phase 2b will implement full reforge_link.sh
##
phase_3_model_links() {
    log_phase "3" "モデルシンボリックリンクの作成" "Model Symlink Creation"

    # Check if reforge_link.sh exists (should be created in Phase 2b)
    if [[ ! -f "${REFORGE_DIR}/reforge_link.sh" ]]; then
        echo "Note: reforge_link.sh not yet created (will be implemented in Phase 2b)"
        echo "メモ: reforge_link.sh はまだ作成されていません（Phase 2bで実装予定）"
        log_success "フェーズ3スキップ" "Phase 3 skipped (Phase 2b pending)"
        return 0
    fi

    # Call reforge_link.sh if it exists
    if ! bash "${REFORGE_DIR}/reforge_link.sh"; then
        # Link creation failures are non-fatal (user can create links manually)
        echo "WARNING: Some symlinks may not have been created" >&2
        echo "警告: いくつかのシンボリックリンクが作成されていない可能性があります" >&2
        return 0
    fi

    log_success "モデルシンボリックリンクが作成されました" "Model symlinks created successfully"
}

##
# Phase 4: Setup other WebUI variants if present
##
phase_4_variants() {
    log_phase "4" "他のWebUIバリアントのセットアップ" "Other WebUI Variants Setup"

    # Setup A1111 if directory exists and script exists
    if [[ -d "${SCRIPT_DIR}/../stable-diffusion-webui" ]] || [[ -d "${SCRIPT_DIR}/../automatic1111" ]]; then
        if [[ -f "${SCRIPT_DIR}/setup_a1111.sh" ]]; then
            echo "Setting up A1111..."
            if ! bash "${SCRIPT_DIR}/setup_a1111.sh"; then
                die "A1111のセットアップに失敗しました" "Failed to setup A1111" 1
            fi
        else
            echo "Note: setup_a1111.sh not found (will skip A1111 setup)"
        fi
    fi

    # Setup Forge if directory exists and script exists
    if [[ -d "${SCRIPT_DIR}/../stable-diffusion-webui-forge" ]] || [[ -d "${SCRIPT_DIR}/../forge" ]]; then
        if [[ -f "${SCRIPT_DIR}/setup_forge.sh" ]]; then
            echo "Setting up Forge..."
            if ! bash "${SCRIPT_DIR}/setup_forge.sh"; then
                die "Forgeのセットアップに失敗しました" "Failed to setup Forge" 1
            fi
        else
            echo "Note: setup_forge.sh not found (will skip Forge setup)"
        fi
    fi

    log_success "バリアントの確認が完了しました" "Variants check completed"
}

##
# Phase 5: Minimum Model Downloads
##
phase_5_downloads() {
    log_phase "5" "初期モデルのダウンロード" "Minimum Model Downloads"

    # Skip if disable flag exists
    if [[ -f "${REFORGE_DIR}/Update_DisableMinimumDownload.txt" ]]; then
        echo "Update_DisableMinimumDownload.txt found. Skipping automatic downloads."
        echo "自動ダウンロードが無効化されています。"
        return 0
    fi

    # Download minimum models using the download engine
    # Tag 'minimum' corresponds to all initial required models.
    local download_engine="${SCRIPT_DIR}/../Download/lib/download_engine.py"
    if [[ -f "$download_engine" ]]; then
        echo "Running minimum model download engine..."
        echo "初期モデルのダウンロードエンジンを実行しています..."
        if ! cd "${SCRIPT_DIR}/.." && uv run python3 "$download_engine" --tag minimum; then
            echo "Warning: Download engine returned an error (continuing)" >&2
        fi
        cd "$SCRIPT_DIR"
    else
        echo "Note: Download engine not found: $download_engine"
    fi

    log_success "初期ダウンロード確認が完了しました" "Initial downloads check completed"
}

##
# Main orchestration
##
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║          ${PROJECT_NAME} Setup Orchestrator                   ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # Execute phases
    phase_1_reforge_environment
    phase_2_reforge_extensions
    phase_3_model_links
    phase_4_variants
    phase_5_downloads

    # Success
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║      セットアップが完了しました！                        ║"
    echo "║      Setup Complete!                                     ║"
    echo "║                                                            ║"
    echo "║  次のステップ / Next Steps:                               ║"
    echo "║  cd $REFORGE_DIR                                          ║"
    echo "║  bash reforge_noptions.sh                                 ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    return 0
}

# Execute main
main "$@"
exit $?
