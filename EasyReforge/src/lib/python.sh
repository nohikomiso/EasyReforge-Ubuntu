#!/bin/bash
# python.sh - Python virtual environment helper library
# Purpose: Replaces EasyTools/Python functionality for venv setup and activation
# Usage: source "${SCRIPT_DIR}/lib/python.sh" && python_create_venv <venv_dir>

set -euo pipefail

# UTF-8 encoding for bilingual support
export LC_ALL=C.UTF-8

##
# python_check_installed - Verify Python 3 is installed and meets version requirements
#
# Arguments:
#   $1 - Minimum Python version (default: 3.10)
#
# Returns:
#   0 if Python 3 is installed and meets requirements
#   1 if Python is not found or version is insufficient
#
# Examples:
#   python_check_installed "3.10"
#   python_check_installed  # Uses default 3.10
##
python_check_installed() {
    local min_version="${1:-3.10}"
    local python_exe
    local python_version

    # Find Python 3 executable
    if command -v python3 &> /dev/null; then
        python_exe="python3"
    elif command -v python &> /dev/null; then
        python_exe="python"
    else
        echo "ERROR (ja): Python 3がインストールされていません" >&2
        echo "ERROR (en): Python 3 is not installed" >&2
        return 1
    fi

    # Get version
    python_version=$("$python_exe" --version 2>&1 | awk '{print $2}')

    # Basic version check (compare major.minor)
    if [[ "$python_version" < "$min_version" ]]; then
        echo "ERROR (ja): Python ${min_version}以上が必要です（現在: ${python_version}）" >&2
        echo "ERROR (en): Python ${min_version}+ required (current: ${python_version})" >&2
        return 1
    fi

    return 0
}

##
# python_create_venv - Create a Python virtual environment
#
# Creates a new Python venv in the specified directory.
# If venv already exists, this function exits early (idempotent).
#
# Arguments:
#   $1 - Path to virtual environment directory (absolute or relative)
#   $2 - Python version requirement (default: 3.10)
#
# Returns:
#   0 on success or if venv already exists
#   1 on failure
#
# Examples:
#   python_create_venv "./venv"
#   python_create_venv "/opt/reforge/venv" "3.10"
##
python_create_venv() {
    local venv_dir="${1:?Virtual environment directory not provided}"
    local python_version="${2:-3.10}"

    # Ensure absolute path
    if [[ ! "$venv_dir" = /* ]]; then
        venv_dir="$(cd "$(dirname "$venv_dir")" && pwd)/$(basename "$venv_dir")"
    fi

    # Check if Python is available
    if ! python_check_installed "$python_version"; then
        return 1
    fi

    # If venv already exists, consider it success (idempotent)
    if [[ -d "$venv_dir/bin" ]] && [[ -f "$venv_dir/bin/python" ]]; then
        return 0
    fi

    # Ensure parent directory exists
    local parent_dir
    parent_dir="$(dirname "$venv_dir")"
    if ! mkdir -p "$parent_dir"; then
        echo "ERROR (ja): ディレクトリ '${parent_dir}' を作成できません" >&2
        echo "ERROR (en): Failed to create directory '${parent_dir}'" >&2
        return 1
    fi

    # Create virtual environment
    if ! python3 -m venv "$venv_dir"; then
        echo "ERROR (ja): 仮想環境の作成に失敗しました: ${venv_dir}" >&2
        echo "ERROR (en): Failed to create virtual environment: ${venv_dir}" >&2
        return 1
    fi

    return 0
}

##
# python_activate_venv - Activate a Python virtual environment
#
# Sources the venv activation script to activate the environment
# in the current shell session.
#
# Arguments:
#   $1 - Path to virtual environment directory
#
# Returns:
#   0 on success
#   1 on failure or if venv doesn't exist
#
# Examples:
#   python_activate_venv "./venv"
#   python_activate_venv "/opt/reforge/venv"
##
python_activate_venv() {
    local venv_dir="${1:?Virtual environment directory not provided}"

    # Ensure absolute path
    if [[ ! "$venv_dir" = /* ]]; then
        venv_dir="$(cd "$(dirname "$venv_dir")" && pwd)/$(basename "$venv_dir")"
    fi

    # Check if venv exists
    if [[ ! -f "$venv_dir/bin/activate" ]]; then
        echo "ERROR (ja): 仮想環境が見つかりません: ${venv_dir}" >&2
        echo "ERROR (en): Virtual environment not found: ${venv_dir}" >&2
        return 1
    fi

    # Source activation script
    # This modifies the current shell session, so we source it
    source "${venv_dir}/bin/activate"

    return 0
}

##
# python_install_requirements - Install Python packages from requirements.txt
#
# Installs packages from a requirements.txt file using pip.
# Requires an activated virtual environment.
#
# Arguments:
#   $1 - Path to requirements.txt file
#   $2 - Optional pip arguments (e.g., "--upgrade")
#
# Returns:
#   0 on success
#   1 on failure
#
# Examples:
#   python_install_requirements "./requirements.txt"
#   python_install_requirements "/opt/reforge/requirements.txt" "--upgrade"
#
# Note:
#   The venv must be activated before calling this function.
##
python_install_requirements() {
    local requirements_file="${1:?Requirements file not provided}"
    local pip_args="${2:-}"

    # Check if file exists
    if [[ ! -f "$requirements_file" ]]; then
        echo "ERROR (ja): 要件ファイルが見つかりません: ${requirements_file}" >&2
        echo "ERROR (en): Requirements file not found: ${requirements_file}" >&2
        return 1
    fi

    # Upgrade pip first
    if ! pip3 install --upgrade pip setuptools wheel > /dev/null 2>&1; then
        echo "WARNING (ja): pipのアップグレードに失敗しました" >&2
        echo "WARNING (en): Failed to upgrade pip (continuing anyway)" >&2
    fi

    # Install requirements
    # shellcheck disable=SC2086
    if ! pip3 install $pip_args -r "$requirements_file"; then
        echo "ERROR (ja): 要件のインストールに失敗しました: ${requirements_file}" >&2
        echo "ERROR (en): Failed to install requirements: ${requirements_file}" >&2
        return 1
    fi

    return 0
}

##
# python_is_venv_activated - Check if a Python venv is currently activated
#
# Verifies that the current Python executable is from a venv.
#
# Returns:
#   0 if a venv is activated
#   1 if no venv is active
#
# Examples:
#   if python_is_venv_activated; then
#       echo "Venv is active"
#   fi
##
python_is_venv_activated() {
    local python_prefix

    # Get the prefix of the current Python installation
    python_prefix="$(python3 -c "import sys; print(sys.prefix)")"

    # Check if VIRTUAL_ENV is set and matches python prefix
    if [[ -n "${VIRTUAL_ENV:-}" ]] && [[ "$VIRTUAL_ENV" == "$python_prefix" ]]; then
        return 0
    fi

    # Also check if python binary is inside a venv directory
    if [[ "$python_prefix" == *"/venv"* ]] || [[ "$python_prefix" == *"/.venv"* ]]; then
        return 0
    fi

    return 1
}

##
# python_get_venv_info - Get information about activated venv
#
# Returns:
#   Path to activated venv (empty if none is active)
##
python_get_venv_info() {
    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        echo "$VIRTUAL_ENV"
    else
        python3 -c "import sys; print(sys.prefix if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix) else '')"
    fi
}

return 0 2> /dev/null || true
