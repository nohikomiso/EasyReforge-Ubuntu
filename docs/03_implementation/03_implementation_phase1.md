# Phase 1 実装手引き - ヘルパーライブラリと基盤スクリプト

**目的**: Phase 1 の詳細な実装ステップバイステップガイド
**対象者**: 実装開発者
**期間**: 1-2週間
**工数**: 10-15時間

---

## 重要: 実装前に必ず読むこと

**バッチファイルの単純な構文置換は禁止です。**

各スクリプトを実装する前に、以下のプロセスに従ってください:

1. **バッチファイルの目的を理解する** - 何を達成しようとしているか
2. **Linux での最適な実装方法を設計する** - Ubuntu のツールとベストプラクティスを使う
3. **shell-scripting Skill を活用する** - 実装時に `Skill shell-scripting` を呼び出す
4. **構文リファレンスは補助的に使う** - `../04_reference/04_reference_conversion_table.md` は最後に参照

**参考資料**:
- `/home/ytsubame/src/_research_reference/ANALYSIS_REPORT.md` - Windows ライブラリ分析
- `docs/03_implementation_common_patterns.md` - バッチファイル分析プロセス（詳細）
- `.claude/CLAUDE.md` - Script Conversion Guidelines セクション

---

## 概要

Phase 1 では以下の 5 つのスクリプトを作成します：

1. **`EasyReforge/src/lib/github.sh`** - Git操作ユーティリティ
2. **`EasyReforge/src/lib/uv.sh`** - Python仮想環境管理（uv専用）
3. **`EasyReforge/easyreforge_installer.sh`** - 起点インストーラー（環境変数カスケード対応）
4. **`update.sh`** - アップデートスクリプト
5. **`setup.sh`** - セットアップスクリプト

---

## Task 1: `EasyReforge/src/lib/github.sh` 実装

### ステップ0: バッチファイル分析（必須）

**実装前に必ず実施**:

```bash
# 1. 関連するWindowsバッチファイルを特定
# EasyEnv/EasyToolsのGit関連スクリプトを参照
cat /home/ytsubame/src/_research_reference/ANALYSIS_REPORT.md | grep -A 20 "Git"

# 2. 目的を理解する
# このスクリプトは「Git リポジトリのクローンまたは更新」を行う
# Windows版では Git for Windows / PortableGit を使用
# Ubuntu版では apt でインストールされた git を使用（ポータブル版不要）

# 3. Linux最適化を検討
# - git clone --depth=1 (shallow clone) でネットワーク効率化
# - git -C オプションでディレクトリ変更不要
# - SSH vs HTTPS の選択肢
```

**shell-scripting Skill を呼び出して実装**:
- `Skill shell-scripting` を使用して、プロフェッショナルなシェルスクリプトを作成

### ステップ1: ファイルを読み込み

まず、元のバッチファイルがあるか確認：

```bash
# Windows版があれば参考にする
find EasyReforge -name "*.bat" | head -10
```

### ステップ2: 関数設計

必要な関数を定義：

```bash
#!/bin/bash
set -euo pipefail

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
    git -C "$destination" fetch origin "$commit_hash" 2>/dev/null || true
    git -C "$destination" checkout "$commit_hash"

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
```

### ステップ3: テスト

```bash
#!/bin/bash

# ライブラリを読み込み
source EasyReforge/src/lib/github.sh

# テスト1: クローン
mkdir -p /tmp/test_repos
github_clone_or_pull "https://github.com/torvalds/linux.git" "/tmp/test_repos/linux"
github_verify_clone "/tmp/test_repos/linux"

# テスト2: エラーハンドリング
github_clone_or_pull "https://invalid-url.git" "/tmp/test_repos/invalid" && echo "FAIL: should have failed" || echo "OK: Error handled"

# テスト3: shellcheck
shellcheck EasyReforge/src/lib/github.sh
```

### 実装ポイント (shell-scriptingスキル)

**Caution**: Git操作の詳細
- `git clone` はリモートから完全コピー（初回）
- `git pull` は既存repoを更新
- `git -C <dir>` は別ディレクトリで実行
- エラーリダイレクト: `2>/dev/null` でサイレント化

---

## Task 2: `EasyReforge/src/lib/uv.sh` 実装 (旧python.sh)

### ステップ1: uv 要件の確認

```bash
# uv が使用可能か確認
# インストールされていない場合は: curl -LsSf https://astral.sh/uv/install.sh | sh
uv --version
```

### ステップ2: 関数設計

```bash
#!/bin/bash
set -euo pipefail

# 関数1: 仮想環境を作成
# 使用例: python_create_venv "/path/to/venv"
python_create_venv() {
    local venv_path="$1"

    if [ -d "$venv_path" ]; then
        echo "Venv already exists at $venv_path"
        return 0
    fi

    echo "Creating virtual environment at $venv_path..."
    # uv init --bare でプロジェクトを初期化し、直後に venv を作成
    local venv_dir
    venv_dir=$(dirname "$venv_path")
    (cd "$venv_dir" && uv init --bare) 2>/dev/null || true
    
    uv venv "$venv_path" --python 3.10

    # 権限設定
    chmod -R u+w "$venv_path"

    return 0
}

# 関数2: 仮想環境でのコマンド実行 (source/activateを廃止)
# 従来は activate スクリプトを呼び出していましたが、Ubuntu移行では常に uv run を使います。
# 仮想環境のパスを VIRTUAL_ENV で指定するだけです。
# 使用例: VIRTUAL_ENV="/path/to/venv" uv run python script.py

# 関数3: パッケージをインストール
# 使用例: python_install_packages "/path/to/venv" "requirements.txt"
python_install_packages() {
    local venv_path="$1"
    local requirements_file="$2"

    if [ ! -f "$requirements_file" ]; then
        echo "Error: requirements file not found: $requirements_file"
        return 1
    fi

    echo "Installing packages from $requirements_file..."
    # pip インストールは `uv pip` を使用 (仮想環境パスを VIRTUAL_ENV で指定)
    VIRTUAL_ENV="$venv_path" uv pip install -r "$requirements_file"

    return 0
}

# 関数4: venv の有効化を検証
# 使用例: python_verify_activation
python_verify_activation() {
    # venv が有効かどうか検証
    if [[ "$VIRTUAL_ENV" == "" ]]; then
        echo "Error: Virtual environment not activated"
        return 1
    fi

    echo "Virtual environment active: $VIRTUAL_ENV"
    return 0
}

# メイン実行
main() {
    : # このファイルはライブラリ
}
```

### ステップ3: テスト

```bash
#!/bin/bash

source EasyReforge/src/lib/uv.sh

# テスト1: venv 作成
uv_create_venv "/tmp/test_venv"

# テスト2: venv 環境でのパッケージインストール（小規模テスト）
echo "requests==2.31.0" > /tmp/test_requirements.txt
VIRTUAL_ENV="/tmp/test_venv" uv pip install -r /tmp/test_requirements.txt

# テスト3: shellcheck
shellcheck EasyReforge/src/lib/uv.sh
```

### 実装ポイント (shell-scriptingスキル)

**重要なポイント**:
- `source bin/activate` は**絶対に使用しない**こと。
- 常に `VIRTUAL_ENV="/path/to/venv" uv run python ...` の形式で実行する。
- pip インストールは `uv pip install` を使い圧倒的に高速化する。

---

## Task 3: `EasyReforge/easyreforge_installer.sh` 実装

### ステップ1: 元のバッチファイルを確認

```bash
cat EasyReforge/EasyReforgeInstaller.bat | head -50
```

### ステップ2: 処理フローを設計

```
easyreforge_installer.sh
├─ 1. 環境チェック
│  ├─ git --version (2.25+)
│  ├─ bash --version (4.0+)
│  ├─ uv --version
│  └─ 空きディスク容量
├─ 2. ディレクトリ構造作成
│  ├─ mkdir -p EasyReforge/Reforge/src
│  └─ mkdir -p Download/lib
├─ 3. EasyTools リポジトリクローン
│  └─ github_clone_or_pull "https://github.com/Zuntan03/EasyTools" "EasyReforge/EasyTools"
└─ 4. setup.sh 呼び出し
```

### ステップ3: スクリプト実装

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# スクリプトディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ヘルパーをインポート
source "${SCRIPT_DIR}/src/lib/github.sh"

# =====================
# 環境検証関数
# =====================

check_requirement() {
    local cmd="$1"
    local min_version="$2"

    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd not found. Please install it."
        echo "On Ubuntu/Debian: sudo apt-get install $cmd"
        exit 1
    fi

    # バージョン確認（オプション）
    if [ -n "$min_version" ]; then
        local version=$("$cmd" --version 2>&1 | head -1)
        echo "✓ $cmd: $version"
    else
        echo "✓ $cmd found"
    fi
}

setup_environment() {
    echo "========================================="
    echo "EasyReforge Ubuntu Installer"
    echo "========================================="
    echo ""

    # UTF-8設定
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8

    # 環境変数カスケードの起点 (ダウンストリームスクリプトへ継承させるため export 必須)
    export PROJECT_NAME="EasyReforge"
    export PROJECT_URL="https://github.com/nohikomiso/EasyReforge-Ubuntu"
    export PROJECT_BRANCH="ubuntu-migration"

    echo "Checking requirements..."
    check_requirement git
    check_requirement bash
    check_requirement uv
    check_requirement curl

    echo ""
    echo "✓ All requirements satisfied"
}

# =====================
# インストール処理
# =====================

main() {
    setup_environment

    # ステップ1: ディレクトリ作成
    echo ""
    echo "Setting up directory structure..."
    mkdir -p "${SCRIPT_DIR}/Reforge/src"
    mkdir -p "${SCRIPT_DIR}/../Download/lib"
    echo "✓ Directories created"

    # ステップ2: EasyTools クローン
    echo ""
    echo "Cloning EasyTools repository..."
    github_clone_or_pull "https://github.com/Zuntan03/EasyTools.git" \
        "${SCRIPT_DIR}/EasyTools"
    echo "✓ EasyTools ready"

    # ステップ3: setup.sh を呼び出し
    echo ""
    echo "Running setup..."
    bash "${SCRIPT_DIR}/setup.sh"
}

main "$@"
```

### テスト

```bash
# 予行実行
bash EasyReforge/easyreforge_installer.sh --help

# 実際の実行（確認済み後）
bash EasyReforge/easyreforge_installer.sh

# shellcheck
shellcheck EasyReforge/easyreforge_installer.sh
```

---

## Task 4 & 5: `update.sh` と `setup.sh`

これらは `easyreforge_installer.sh` の複雑度が低いため、省略します。

基本的な構造：

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/src/lib/github.sh"

main() {
    # 実装
}

main "$@"
```

---

## テスト・検証ガイド

### Phase 1 検証チェックリスト

- [ ] `shellcheck` が全スクリプトをパス
- [ ] `github.sh` のクローン・プル機能が動作
- [ ] `uv.sh` の venv 作成が動作
- [ ] `easyreforge_installer.sh` がエラーなく実行完了
- [ ] `setup.sh` が `easyreforge_installer.sh` から呼び出せる
- [ ] `update.sh` が既存環境を更新できる

### テストスクリプト例

```bash
#!/bin/bash

# test_phase1.sh

TEST_DIR="/tmp/easyreforge_test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "=== Testing Phase 1 Scripts ==="

# テスト1: github.sh
echo "Testing github.sh..."
source ./lib/github.sh 2>/dev/null && echo "✓ github.sh loads" || echo "✗ github.sh failed"

# テスト2: uv.sh
echo "Testing uv.sh..."
source ./lib/uv.sh 2>/dev/null && echo "✓ uv.sh loads" || echo "✗ uv.sh failed"

# テスト3: shellcheck
echo "Testing shellcheck..."
for script in ./lib/*.sh ./*.sh; do
    shellcheck "$script" && echo "✓ $script" || echo "✗ $script"
done

echo "=== Phase 1 Tests Complete ==="
```

---

## Shell-Scripting スキル活用ガイド

このPhase 1で学べるスキル：

### 1. エラーハンドリング
```bash
set -euo pipefail       # 厳密なエラーチェック
trap 'cleanup' EXIT     # 終了時処理
command || return 1     # エラーハンドリング
```

### 2. 条件判定
```bash
[ -d "$dir" ] && echo "exists" || echo "not found"
[[ "$var" == "value" ]] && action
```

### 3. コマンド実行制御
```bash
command -v git          # コマンド存在確認
"$cmd" --version        # バージョン確認
git -C "$dir" status    # 別ディレクトリで実行
```

### 4. 関数設計
```bash
function_name() {
    local param="$1"    # ローカル変数
    return 0            # 終了コード
}
```

---

## よくある問題と対処法

### 問題1: `source` が機能しない
**原因**: パスが相対パスの場合、実行ディレクトリに依存
**対処**: 絶対パスを使用
```bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/github.sh"
```

### 問題2: Git が見つからない
**原因**: Ubuntu に git がインストールされていない
**対処**:
```bash
sudo apt-get update
sudo apt-get install -y git
```

### 問題3: uv が見つからない / 機能しない
**原因**: uv コマンドがインストールされていないかパスが通っていない
**対処**:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env
```

---

## 次のステップ

Phase 1 完了後、以下の確認をしてください：

1. **Git リポジトリに追加**
   ```bash
   git add EasyReforge/src/lib/
   git add EasyReforge/*.sh
   git commit -m "Phase 1: Add helper libraries and installer scripts"
   ```

2. **Phase 2 準備**
   - `reforge.sh` の実装
   - PyTorch インストール処理の設計

3. **ドキュメント更新**
   - CLAUDE.md の進捗を更新
   - README にセットアップ手順を追加

---

**作成日**: 2025-12-03
**ステータス**: Phase 1 準備完了
**次フェーズ**: Phase 2 (reforge.sh の実装)

