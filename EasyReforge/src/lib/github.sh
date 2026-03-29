#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# 関数1: クローンまたはプル
# 使用例: github_clone_or_pull "https://github.com/user/repo.git" "/path/to/repo"
github_clone_or_pull() {
    local repo_url="$1"
    local destination="$2"

    # 1. ディレクトリがなければクローン
    if [ ! -d "$destination" ]; then
        echo "Cloning $repo_url to $destination..."
        git clone "$repo_url" "$destination"
        return 0
    fi

    # 2. ディレクトリがあればプル
    if git -C "$destination" rev-parse --git-dir >/dev/null 2>&1; then
        echo "Pulling latest from $destination..."
        git -C "$destination" pull --quiet
        return 0
    fi

    # 3. エラー: ディレクトリは存在するがGit repoではない
    echo "Error: $destination is not a Git repository"
    return 1
}

# 関数2: 特定コミットをチェックアウト
# 使用例: github_fetch_commit "https://github.com/user/repo.git" "abc123def456" "/path/to/repo"
github_fetch_commit() {
    local repo_url="$1"
    local commit_hash="$2"
    local destination="$3"

    # 1. リポジトリがなければクローン
    if [ ! -d "$destination" ]; then
        git clone "$repo_url" "$destination"
    fi

    # 2. コミットをチェックアウト
    # [Logical Fix] WebUI の Detached HEAD エラーを抑制するため、
    # 特定コミットに対して 'fixed-version' というブランチ名を強制付与します。
    git -C "$destination" fetch origin "$commit_hash" 2>/dev/null || true
    git -C "$destination" checkout -B fixed-version "$commit_hash"

    return 0
}

# 関数3: クローン検証
# 使用例: github_verify_clone "/path/to/repo"
github_verify_clone() {
    local repo_path="$1"

    if [ ! -d "$repo_path" ]; then
        echo "Error: $repo_path does not exist"
        return 1
    fi

    if ! git -C "$repo_path" rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: $repo_path is not a Git repository"
        return 1
    fi

    # .git フォルダの大きさをチェック（ダウンロード成功の目安）
    if [ ! -d "$repo_path/.git" ]; then
        echo "Error: .git folder missing"
        return 1
    fi

    return 0
}

# メイン実行（テスト用）
main() {
    : # このファイルはライブラリなので、直接実行されない
}
