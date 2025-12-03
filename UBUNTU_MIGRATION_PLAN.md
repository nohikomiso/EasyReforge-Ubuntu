# EasyReforge Ubuntu移行計画 - Shell-Scripting統合版

**状態**: 実装準備完了
**最終更新**: 2025-12-03
**総スコープ**: 237 .bat ファイル → シェルスクリプト変換
**予想期間**: 10-12週間（フル）/ 4-5週間（コア機能）

---

## 概要

このドキュメントは、EasyReforgeを**Windows限定**から**Ubuntu限定**への移行を計画しています。
237個の.batファイルを同等の機能を持つシェルスクリプト(.sh)に変換し、CLAUDE.mdで定義されたアーキテクチャに従います。

**重要**: このプロジェクトは単なる「バッチファイル翻訳」ではなく、**Ubuntuでの同等機能の再実装**です。

---

## Phase 1: 基盤スクリプト（1-2週間、4-6時間/スクリプト）

### 目標
コア基盤が完成し、すべてのスクリプトがこの上に構築できる状態

### Phase 1.1: ヘルパーライブラリ作成

#### Task 1: `EasyReforge/src/lib/github.sh` 作成
**ファイル**: `EasyReforge/src/lib/github.sh`

```bash
# 責務: GitHub リポジトリのクローン/プル操作
# 関数:
#   - github_clone_or_pull(repo_url, destination)
#   - github_fetch_commit(repo_url, commit_hash, destination)
#   - github_verify_clone(repo_path)
```

**実装ポイント**:
- Git操作の基本（クローン、プル、チェックアウト）
- エラーハンドリング（既存ディレクトリ処理）
- ネットワークタイムアウト対応
- 進捗表示（オプション）

**参考**: SCRIPT_CONVERSION_REFERENCE.md の Git操作セクション

**shell-scriptingスキル活用**:
```bash
# Gitサブモジュール管理
# Git操作のベストプラクティス
# エラーハンドリングパターン
```

---

#### Task 2: `EasyReforge/src/lib/python.sh` 作成
**ファイル**: `EasyReforge/src/lib/python.sh`

```bash
# 責務: Python仮想環境管理
# 関数:
#   - python_create_venv(venv_path)
#   - python_activate_venv(venv_path)
#   - python_install_packages(venv_path, requirements_file)
#   - python_verify_activation()
```

**実装ポイント**:
- Python 3.10+検出
- 仮想環境作成と有効化
- 要件ファイルインストール
- 活性化検証

**重要な注意**: Windows vs Linuxの違い
- Windows: `venv\Scripts\activate.bat`
- Ubuntu: `source venv/bin/activate`

**shell-scriptingスキル活用**:
```bash
# 仮想環境の正しい有効化方法
# Pythonプロセス確認
# 環境変数の永続化
```

---

### Phase 1.2: 主要スクリプト変換

#### Task 3: `EasyReforge/easyreforge_installer.sh` 変換
**ファイル**: `EasyReforge/easyreforge_installer.bat` → `EasyReforge/easyreforge_installer.sh`

**元ファイルから除去する部分** (Windows固有):
- PowerShellパス検証ロジック
- VC Runtime チェック
- レジストリ長パス設定
- ポータブルGit ロジック

**新規追加（Ubuntu固有）**:
- Gitインストール検証 (`git --version`)
- BashバージョンチェックΔ (`bash --version`)
- UTF-8ロケール設定 (`export LC_ALL=C.UTF-8`)

**主な処理フロー**:
1. 環境検証（必要ツール確認）
2. EasyToolsリポジトリのクローン
3. EasyReforgeディレクトリ初期化
4. `setup.sh` への呼び出し

**実装時間**: 3-4時間
**shell-scriptingスキル活用**: エラーハンドリング、環境検証パターン

---

#### Task 4: `update.sh` 変換
**ファイル**: `Update.bat` → `update.sh`

**機能**:
- EasyReforge全体の更新
- reForge WebUIのアップデート
- 拡張機能の更新
- 設定の後方互換性確保

**実装時間**: 3-4時間

---

#### Task 5: `setup.sh` 変換
**ファイル**: `Setup.bat` → `setup.sh`

**機能**:
- インストール環境のチェック
- reForgeバリアントの選択
- A1111/Forgeの代替オプション

**実装時間**: 3-4時間

---

## Phase 2: コア環境セットアップ（3-4週間、30-40時間/主要スクリプト）

### 目標
reForge WebUIが完全に起動し、画像生成が可能な状態

### Critical Priority: `reforge.sh` 変換

**ファイル**: `EasyReforge/Reforge/Reforge.bat` → `EasyReforge/Reforge/reforge.sh`

**複雑性レベル**: ⭐⭐⭐⭐⭐ (最高難易度)
**予想時間**: 40-50時間
**重要度**: 最高

#### 主要な実装課題

##### 1. PyTorch プラットフォーム固有ホイール
```bash
# Windows: torch-2.7.1+cu128-cp311-cp311-win_amd64.whl
# Ubuntu:  torch-2.7.1+cu128-cp311-cp311-manylinux2014_x86_64.whl

# 実装: GPU検出 → 正しいwheelダウンロード
nvidia-smi  # NVIDIA GPUの検証
```

**注意点**:
- GPUなし時はCPU版を使用
- ホイール取得失敗時はソースビルド
- ダウンロード処理の最適化

**shell-scriptingスキル活用**:
```bash
# 外部コマンドの実行と結果確認
# エラーハンドリング（フォールバック）
# 条件分岐と選択肢の実装
```

---

##### 2. SageAttention ホイール互換性
```bash
# Windows wheel が Linux で利用不可
# ソリューション:
# 1. Linux manylinux版がある場合はそれを使用
# 2. なければソースビルド
```

**実装ポイント**:
- ホイール利用可能性の事前チェック
- ビルド時間の最適化（キャッシング）

---

##### 3. 要件ファイル インストール
```bash
# EasyReforge/Reforge/src/requirements.txt
# 198個のPythonパッケージをインストール
pip3 install -r requirements.txt
```

**最適化**:
- キャッシング戦略
- ネットワークエラーリトライ
- 進捗表示

**shell-scriptingスキル活用**:
```bash
# pipコマンド実行とキャッシング
# ネットワークエラーハンドリング
# ログファイル管理
```

---

##### 4. 環境変数セットアップ
```bash
# CUDA対応PyTorchの正しい初期化
export CUDA_LAUNCH_BLOCKING=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# メモリ管理
export CUDA_VISIBLE_DEVICES=0  # (GPU選択)
```

---

#### reforge.sh 実装フロー
```
1. 環境検証
   ├─ Python 3.10+
   ├─ NVIDIA GPU (オプション)
   ├─ CUDA Toolkit
   └─ 空きディスク容量 (20GB+)

2. 仮想環境セットアップ
   ├─ venv作成 (lib/python.sh)
   ├─ venv有効化
   └─ 有効化検証

3. PyTorchインストール
   ├─ GPU検出 (nvidia-smi)
   ├─ 正しいwheel決定
   ├─ wheel ダウンロード
   ├─ インストール
   └─ 動作確認

4. 要件ファイルインストール
   ├─ requirements.txt解析
   ├─ パッケージ インストール
   ├─ エラーハンドリング
   └─ 進捗表示

5. WebUI初期化
   ├─ submodule初期化 (github.sh)
   ├─ reForge初期化
   └─ 起動準備
```

---

### Phase 2 の他のスクリプト

#### Task: `reforge_extension.sh` 変換
**機能**: 13個のGitHub拡張機能をインストール

```bash
# 拡張機能リスト (各エントリ):
# - repo_url
# - commit_hash (再現性確保)
# - destination_path
```

**実装時間**: 6-8時間

**shell-scriptingスキル活用**: Git操作（lib/github.sh活用）

---

#### Task: `reforge_link.sh` 変換
**機能**: モデルディレクトリのシンボリックリンク作成

```bash
# Windows: MKLINK /J (ジャンクション)
# Ubuntu:  ln -s (シンボリックリンク)

# テスト: test -L で検証
```

**実装時間**: 4-5時間

---

#### Task: `reforge_config.sh` 変換
**機能**: 設定ファイルの移行・更新

```bash
# reforge_update_config.py を呼び出し
# 後方互換性確保
```

**実装時間**: 3-4時間

---

#### Task: `reforge_ui_config.sh` 変換
**機能**: UI設定ファイルの移行

```bash
# reforge_update_ui-config.py を呼び出し
# スタイルCSVの管理
```

**実装時間**: 3-4時間

---

#### Task: Root Launcher `reforge.sh` (実行スクリプト)
**ファイル**: `EasyReforge/reforge.sh`
**機能**: WebUIの起動

**実装時間**: 2-3時間

---

## Phase 3: ダウンロード ヘルパーライブラリ（5-6週間、25-35時間）

### 目標
176個のモデルダウンロードスクリプト自動生成の基盤完成

### Phase 3.1: ヘルパーライブラリ実装

#### ライブラリ1: `Download/lib/common.sh`
**責務**: 共通ユーティリティ

```bash
# 関数:
#   - log_info(message)
#   - log_error(message)
#   - download_with_retry(url, output_file, max_retries)
#   - extract_filename_from_url(url)
#   - validate_file_integrity(file, checksum)
```

**実装時間**: 5-6時間

---

#### ライブラリ2: `Download/lib/civitai_download.sh`
**責務**: Civitai APIからのモデルダウンロード

```bash
# 関数:
#   - civitai_download(model_id, filename, output_dir)
#   - civitai_get_download_url(model_id, filename)
#   - civitai_verify_api_key(api_key)
```

**依存する66個のスクリプト**:
- `Download/Stable-diffusion/` の大多数
- `Download/Lora/` の一部

**実装時間**: 7-9時間

**shell-scriptingスキル活用**:
```bash
# HTTPリクエスト (curl)
# JSONパース (jq)
# APIエラーハンドリング
# レート制限対応
```

---

#### ライブラリ3: `Download/lib/huggingface_download.sh`
**責務**: Hugging Face Hub からのダウンロード

```bash
# 関数:
#   - huggingface_download(model_id, filename, output_dir)
#   - huggingface_list_files(model_id)
```

**依存する59個のスクリプト**:
- `Download/Stable-diffusion/` の一部
- `Download/Lora/` の大多数

**実装時間**: 6-8時間

---

#### ライブラリ4-7: その他のダウンロードヘルパー
- `civitai_download_unzip.sh` (21スクリプト依存)
- `huggingface_hub_download.sh` (4スクリプト依存)
- `aria_download.sh` (直接ダウンロード, 4スクリプト依存)
- `recursive_call.sh` (ディレクトリ再帰)

**合計実装時間**: 8-10時間

---

### Phase 3.2: メタデータ抽出ツール

**タスク**: 176個の.batファイルからメタデータCSVを生成

```csv
script_name, model_type, download_method, civitai_model_id, huggingface_model_id, direct_url, output_dir, dependencies
NoobE_v11.sh, Stable-diffusion, civitai, 833294, (null), (null), Model/Stable-diffusion, common.sh
```

**実装時間**: 4-6時間

**shell-scriptingスキル活用**:
```bash
# テキスト処理 (sed, awk, grep)
# 正規表現によるURL抽出
# バッチ処理とループ
```

---

## Phase 4: モデルスクリプト生成（7-8週間、30-40時間）

### 目標
165以上のモデルダウンロードスクリプトを自動生成・検証

### Phase 4.1: 自動スクリプト生成

**タスク**: メタデータCSVからシェルスクリプトを自動生成

```bash
# テンプレート:
#!/bin/bash
set -euo pipefail

MODEL_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/../../lib/civitai_download.sh"

main() {
    civitai_download "model_id" "filename" "output_dir"
}

main "$@"
```

**自動化ツール**:
- Pythonスクリプト or Bashスクリプト
- CSVを入力として読み込み
- 各スクリプトを生成

**実装時間**: 8-10時間

---

### Phase 4.2: メタスクリプト変換

**タスク**: 20個の「All」メタスクリプト

```bash
# Download/All/AllStable-diffusion.sh
# 効果: すべてのStable-diffusionモデルをダウンロード

#!/bin/bash
source "${SCRIPT_DIR}/../lib/recursive_call.sh"

recursive_call "${SCRIPT_DIR}/../Stable-diffusion" "$@"
```

**実装時間**: 6-8時間

---

### Phase 4.3: 検証と最適化

**検証項目**:
- shellcheck 全スクリプト
- ドライラン実行 (`DRY_RUN=1`)
- メタスクリプトが子スクリプトを正しく呼び出す

**実装時間**: 6-8時間

**shell-scriptingスキル活用**:
```bash
# バッチ検証スクリプト
# ドライランモードの実装
# エラーレポート生成
```

---

## Phase 2b: モデルリンキングスクリプト（並行実施、9-10週間、15-20時間）

### 目標
ユーザーが外部モデルディレクトリをシンボリックリンクで接続可能に

### Phase 2b.1: テンプレート作成

#### Template 1: `link_input.sh`
**機能**: 外部ソースをWebUIにリンク

```bash
# 使用例:
# bash link_input.sh /external/models/

# 効果:
# Model/Stable-diffusion → /external/models/Stable-diffusion へリンク
```

**実装時間**: 4-5時間

---

#### Template 2: `link_output.sh`
**機能**: 出力ディレクトリをリンク

**実装時間**: 3-4時間

---

### Phase 2b.2: 複製

**タスク**: 7つのモデルカテゴリに複製

- Stable-diffusion/
- Lora/
- ControlNet/
- VAE/
- ESRGAN/
- adetailer/
- wildcards/

**実装時間**: 2-3時間（自動化可能）

---

## Phase 5: オプション機能・最適化（11-12週間、15-25時間）

### Phase 5.1: ランチャースクリプト

#### Task: 8個のreForgeランチャー変換
- `reforge_gpu.sh` - GPU有効時の起動
- `reforge_cpu.sh` - CPU-onlyモード
- その他バリアント

**実装時間**: 6-8時間

---

#### Task: 8個のLLM推論スクリプト
- `llm_inference.sh`
- その他変換

**実装時間**: 4-6時間

---

### Phase 5.2: エンドツーエンド検証

**タスク**: 複数のUbuntuバージョンでのテスト

- Ubuntu 18.04
- Ubuntu 20.04
- Ubuntu 22.04

**実装時間**: 4-6時間

---

## 実装戦略: Shell-Scripting スキルの活用

### スキル1: エラーハンドリングパターン

```bash
# パターン1: 基本的なエラー処理
set -euo pipefail
trap 'echo "Error at line $LINENO"; exit 1' ERR

# パターン2: リトライロジック
retry() {
    local max_attempts=3
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        echo "Attempt $attempt failed, retrying..."
        ((attempt++))
        sleep 2
    done
    return 1
}

# パターン3: クリーンアップ処理
cleanup() {
    rm -f "$TEMP_FILE"
    kill $PID 2>/dev/null || true
}
trap cleanup EXIT
```

**活用フェーズ**: Phase 1, 2, 3, 4 全段階

---

### スキル2: ファイル操作と検証

```bash
# チェック1: ファイル存在確認
if [ ! -f "$file" ]; then
    echo "Error: $file not found"
    exit 1
fi

# チェック2: ディレクトリ検証
if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
fi

# チェック3: 読み取り権限確認
if [ ! -r "$file" ]; then
    chmod +r "$file"
fi

# チェック4: シンボリックリンク検証
if [ -L "$link" ]; then
    target=$(readlink "$link")
    echo "Link points to: $target"
fi
```

**活用フェーズ**: Phase 2, 2b, 3

---

### スキル3: 外部コマンド実行と制御

```bash
# 方法1: コマンド出力をキャプチャ
version=$(git --version | awk '{print $3}')

# 方法2: 終了コード確認
if git clone "$url" "$dest"; then
    echo "Clone succeeded"
else
    echo "Clone failed with code $?"
fi

# 方法3: パイプの統合処理
cat requirements.txt | while read package; do
    pip install "$package" || echo "Failed: $package"
done

# 方法4: 背景プロセス管理
long_task &
PID=$!
wait $PID
```

**活用フェーズ**: Phase 1, 2, 3, 4

---

### スキル4: 環境変数と設定管理

```bash
# パターン1: デフォルト値
MODEL_DIR="${MODEL_DIR:-/opt/models}"
VENV_PATH="${VENV_PATH:-$HOME/.venv}"

# パターン2: 環境ファイルのソース
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# パターン3: 一時的な環境変数設定
(
    export CUDA_VISIBLE_DEVICES=0
    python train.py
)

# パターン4: 検証とセット
set_nvidia_env() {
    if ! command -v nvidia-smi &>/dev/null; then
        echo "NVIDIA drivers not found, using CPU"
        export CUDA_VISIBLE_DEVICES=""
    fi
}
```

**活用フェーズ**: Phase 1, 2, 4

---

### スキル5: テキスト処理とデータ抽出

```bash
# パターン1: テキストフィルタリング
grep "error\|warning" logfile.txt

# パターン2: 行処理とループ
while IFS=',' read -r name version url; do
    download "$url" -o "$name-$version.tar.gz"
done < models.csv

# パターン3: 複数ファイルの処理
find Download -name "*.bat" -type f | while read file; do
    convert_batch_to_shell "$file"
done

# パターン4: テキスト置換と変換
sed 's/\.bat/\.sh/g' script.txt
awk '{print $1, $2}' data.txt
```

**活用フェーズ**: Phase 3 (メタデータ抽出), Phase 4

---

### スキル6: 関数設計と再利用

```bash
# 関数テンプレート: 入出力と検証
download_model() {
    local model_id="$1"
    local output_dir="$2"

    # 入力検証
    if [ -z "$model_id" ] || [ -z "$output_dir" ]; then
        echo "Error: missing arguments"
        return 1
    fi

    # 実装
    curl -L "$API_URL/models/$model_id" -o "$output_dir/model.bin"

    # 出力検証
    if [ -f "$output_dir/model.bin" ]; then
        return 0
    else
        return 1
    fi
}

# 使用例
if download_model "noob-e-v11" "/path/to/models"; then
    echo "Success"
else
    echo "Failed"
fi
```

**活用フェーズ**: Phase 1, 2, 3 (ヘルパーライブラリ)

---

## 依存関係グラフ

```
Phase 1.1: Helper Libraries (GitHub, Python)
    ↓
Phase 1.2: Core Scripts (easyreforge_installer, update, setup)
    ↓
Phase 2: Core Environment (reforge.sh ← github.sh + python.sh)
    ├─→ Phase 2b: Model Linking (並行)
    └─→ Phase 3: Download Helpers
        ↓
        Phase 4: Model Scripts Generation
```

**クリティカルパス**: Phase 1 → Phase 2 (reforge.sh) → Phase 3 → Phase 4

---

## テスト戦略

### Phase 1テスト
```bash
# ヘルパーライブラリテスト
shellcheck EasyReforge/src/lib/github.sh
source EasyReforge/src/lib/github.sh
github_clone_or_pull "https://github.com/test/repo" "/tmp/test_repo"

# メインスクリプトテスト
bash EasyReforge/easyreforge_installer.sh --dry-run
```

### Phase 2テスト
```bash
# 環境検証
python3 --version  # 3.10+確認
bash reforge.sh --check-deps

# WebUI起動テスト
bash EasyReforge/Reforge/reforge.sh
# ブラウザで http://localhost:7860 にアクセス
```

### Phase 3テスト
```bash
# ダウンロードヘルパーテスト
source Download/lib/common.sh
source Download/lib/civitai_download.sh
DRY_RUN=1 civitai_download "model_id" "filename" "output_dir"
```

### Phase 4テスト
```bash
# スクリプト検証
for script in Download/**/*.sh; do
    shellcheck "$script"
done

# ドライランテスト
for script in Download/**/*.sh; do
    DRY_RUN=1 bash "$script"
done
```

---

## スケジュール概要

| 週 | フェーズ | タスク | 時間 |
|----|---------|--------|------|
| 1-2 | Phase 1 | ヘルパーライブラリ + メインスクリプト | 10-15h |
| 3-4 | Phase 2 | reforge.sh (CRITICAL) + 関連スクリプト | 50-60h |
| 5-6 | Phase 3 | ダウンロードヘルパー + メタデータ | 30-40h |
| 7-8 | Phase 4 | スクリプト自動生成 + 検証 | 30-40h |
| 9-10 | Phase 2b | モデルリンキング (並行) | 15-20h |
| 11-12 | Phase 5 | ランチャー + QA | 20-25h |

**合計**: 155-200時間 (10-12週間)

---

## 成功条件

実装が完了したと判断する基準:

- [ ] 全237個のバッチファイルに対応する.shファイルが存在
- [ ] コア基盤がUbuntu 18.04+で動作
- [ ] WebUIが起動でき画像生成が可能
- [ ] モデルダウンロードが機能
- [ ] シンボリックリンクが機能してPythonから読み込み可能
- [ ] すべてのスクリプトが`shellcheck`検証合格
- [ ] すべてのスクリプトに適切なエラーハンドリングがある
- [ ] ドキュメント完全
- [ ] 複数のUbuntuバージョンでテスト済み
- [ ] ユーザーワークフローに変更なし
- [ ] 日本語UI完全機能（UTF-8）

---

## 次のステップ

1. **今すぐ**: Phase 1 の Task 1 開始 (`EasyReforge/src/lib/github.sh` 作成)
2. **準備**: 元のバッチファイルをローカルで確認
3. **テスト**: 各スクリプト完成後に`shellcheck`で検証
4. **追跡**: このドキュメントのチェックリストで進捗管理

---

**更新日**: 2025-12-03
**状態**: 実装準備完了
**責任**: EasyReforge Ubuntu移行チーム

