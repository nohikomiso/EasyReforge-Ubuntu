#!/bin/bash
# github.sh - GitHub repository clone/pull helper library
# Purpose: Replaces EasyTools/Git functionality for repository management
# Usage: source "${SCRIPT_DIR}/lib/github.sh" && github_clone_or_pull <repo_dir> <repo_url> <branch>

set -euo pipefail

# UTF-8 encoding for bilingual support
export LC_ALL=C.UTF-8

##
# github_clone_or_pull - Initialize or update a Git repository
#
# This function implements idempotent Git operations:
# 1. If repo doesn't exist: git init + remote add + fetch + switch
# 2. If repo exists: fetch + switch (to ensure latest branch state)
#
# Arguments:
#   $1 - Repository directory path (absolute or relative)
#   $2 - Repository URL (e.g., https://github.com/user/repo)
#   $3 - Branch name (default: main)
#
# Returns:
#   0 on success
#   1 on failure (with error message to stderr)
#
# Examples:
#   github_clone_or_pull "./MyRepo" "https://github.com/user/repo" "main"
#   github_clone_or_pull "/opt/tools" "https://github.com/org/lib" "develop"
##
github_clone_or_pull() {
    local repo_dir="${1:?Repository directory not provided}"
    local repo_url="${2:?Repository URL not provided}"
    local branch="${3:-main}"

    # Ensure absolute path for consistency
    if [[ ! "$repo_dir" = /* ]]; then
        repo_dir="$(cd "$(dirname "$repo_dir")" && pwd)/$(basename "$repo_dir")"
    fi

    # Check if repository already exists
    if [[ ! -d "$repo_dir/.git" ]]; then
        # New repository: Initialize from scratch
        if ! mkdir -p "$repo_dir"; then
            echo "ERROR (ja): リポジトリディレクトリ '${repo_dir}' を作成できません" >&2
            echo "ERROR (en): Failed to create repository directory '${repo_dir}'" >&2
            return 1
        fi

        if ! git -C "$repo_dir" init; then
            echo "ERROR (ja): リポジトリ '${repo_dir}' の初期化に失敗しました" >&2
            echo "ERROR (en): Failed to initialize repository at '${repo_dir}'" >&2
            return 1
        fi

        # Add remote origin
        if ! git -C "$repo_dir" remote add origin "$repo_url"; then
            echo "ERROR (ja): リモート 'origin' の追加に失敗しました: ${repo_url}" >&2
            echo "ERROR (en): Failed to add remote 'origin': ${repo_url}" >&2
            return 1
        fi
    fi

    # Fetch latest references from remote
    if ! git -C "$repo_dir" fetch origin; then
        echo "ERROR (ja): リポジトリをフェッチできません: ${repo_url}" >&2
        echo "ERROR (en): Failed to fetch repository: ${repo_url}" >&2
        return 1
    fi

    # Switch/checkout to desired branch
    # Use switch if available (Git 2.23+), fallback to checkout
    if git -C "$repo_dir" switch "$branch" &> /dev/null; then
        : # Success with switch
    elif git -C "$repo_dir" checkout "$branch" &> /dev/null; then
        : # Success with checkout (older Git)
    elif git -C "$repo_dir" checkout --track "origin/${branch}" &> /dev/null; then
        : # Success tracking remote branch
    else
        echo "ERROR (ja): ブランチ '${branch}' に切り替えられません" >&2
        echo "ERROR (en): Failed to checkout branch '${branch}'" >&2
        return 1
    fi

    return 0
}

##
# github_validate_url - Validate GitHub repository URL format
#
# Arguments:
#   $1 - Repository URL to validate
#
# Returns:
#   0 if valid GitHub URL
#   1 if invalid format
#
# Accepts formats:
#   - https://github.com/user/repo
#   - https://github.com/user/repo.git
#   - git@github.com:user/repo
#   - git@github.com:user/repo.git
##
github_validate_url() {
    local url="${1:?URL not provided}"

    # Simple URL validation for GitHub
    if [[ "$url" =~ ^(https://github\.com/|git@github\.com:)[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+(.git)?$ ]]; then
        return 0
    else
        return 1
    fi
}

##
# github_get_repo_name - Extract repository name from URL
#
# Arguments:
#   $1 - Repository URL
#
# Returns:
#   Repository name (without .git extension if present)
#
# Examples:
#   github_get_repo_name "https://github.com/user/repo" → "repo"
#   github_get_repo_name "https://github.com/user/repo.git" → "repo"
##
github_get_repo_name() {
    local url="${1:?URL not provided}"
    local name

    # Extract last component of URL path
    name="${url##*/}"

    # Remove .git extension if present
    name="${name%.git}"

    echo "$name"
}

return 0 2> /dev/null || true
