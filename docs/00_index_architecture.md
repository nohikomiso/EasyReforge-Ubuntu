# アーキテクチャ概要 - EasyReforge Ubuntu

**最終更新**: 2025-12-03

---

## システムアーキテクチャ

EasyReforge Ubuntuは、reForge WebUI（Stable Diffusion）のターンキーインストーラーとして、以下の3層構造で設計されています。

```
┌─────────────────────────────────────────────────────────┐
│          ユーザーインターフェース層                        │
│  - easyreforge_installer.sh (初回インストール)            │
│  - update.sh (アップデート)                               │
│  - setup.sh (セットアップ)                                │
│  - reforge.sh (WebUI起動)                                │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│          コア環境セットアップ層                            │
│  - reforge.sh (環境構築: PyTorch, venv, 依存関係)         │
│  - reforge_extension.sh (拡張機能インストール)            │
│  - reforge_link.sh (シンボリックリンク作成)               │
│  - reforge_config.sh (設定移行)                          │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│          ヘルパーライブラリ層                              │
│  - github.sh (Gitリポジトリ操作)                          │
│  - python.sh (Python仮想環境管理)                        │
│  - link_helper.sh (シンボリックリンクユーティリティ)       │
│  - common.sh (共通関数)                                  │
│  - civitai_download.sh (Civitai API)                    │
│  - huggingface_download.sh (HuggingFace API)            │
└─────────────────────────────────────────────────────────┘
```

---

## ディレクトリ構造

### コアディレクトリ

```
EasyReforge-Ubuntu/
├── EasyReforge/                    # メインインストール
│   ├── src/lib/                   # ヘルパーライブラリ
│   │   ├── github.sh              # Git操作
│   │   └── python.sh              # Python venv管理
│   │
│   └── Reforge/                   # reForgeバリアント
│       ├── src/
│       │   ├── requirements.txt   # Python依存関係
│       │   ├── link_helper.sh     # リンク管理
│       │   └── stable-diffusion-webui-reForge/  # Git submodule
│       │
│       ├── reforge.sh             # 環境セットアップ
│       ├── reforge_extension.sh   # 拡張機能
│       ├── reforge_link.sh        # シンボリックリンク
│       └── Reforge_NoOptions.sh   # ランチャー
│
├── Download/                      # モデルダウンロード
│   ├── lib/                       # ダウンロードヘルパー
│   │   ├── common.sh
│   │   ├── civitai_download.sh
│   │   └── huggingface_download.sh
│   │
│   ├── Stable-diffusion/          # モデルカテゴリ
│   ├── Lora/
│   └── ControlNet/
│
└── Model/                         # モデルリンキング
    ├── Stable-diffusion/
    │   ├── link_input.sh
    │   └── link_output.sh
    └── ...
```

---

## データフロー

### 1. インストールフロー

```
ユーザー
  ↓
easyreforge_installer.sh
  ↓
  ├→ 環境検証（Git, Python, Bash）
  ├→ EasyToolsクローン (github.sh)
  └→ setup.sh 呼び出し
      ↓
      ├→ reforge.sh 実行
      │   ├→ venv作成 (python.sh)
      │   ├→ PyTorchインストール
      │   ├→ requirements.txt インストール
      │   └→ reForge submodule 初期化
      │
      ├→ reforge_extension.sh 実行
      │   └→ 13個の拡張機能クローン (github.sh)
      │
      └→ reforge_link.sh 実行
          └→ シンボリックリンク作成 (link_helper.sh)
```

### 2. モデルダウンロードフロー

```
ユーザー
  ↓
bash Download/Stable-diffusion/NoobE/AniKawa.sh
  ↓
  ├→ common.sh 読み込み
  ├→ civitai_download.sh 読み込み
  │   ├→ API URLエンドポイント構築
  │   ├→ curl でダウンロード
  │   └→ エラーハンドリング
  └→ Model/Stable-diffusion/ に保存
```

### 3. WebUI起動フロー

```
ユーザー
  ↓
bash reforge.sh
  ↓
  ├→ venv有効化 (python.sh)
  ├→ 環境変数セット（CUDA, UTF-8）
  └→ python webui.py 実行
      ↓
      WebUI起動（http://localhost:7860）
```

---

## 主要コンポーネント

### 1. ヘルパーライブラリ（Helper Libraries）

#### github.sh

**責務**: Git リポジトリ操作

**関数**:
- `github_clone_or_pull(repo_url, destination)`: クローンまたはプル
- `github_fetch_commit(repo_url, commit_hash, destination)`: 特定コミット取得
- `github_verify_clone(repo_path)`: クローン検証

**使用箇所**: reforge.sh, reforge_extension.sh, easyreforge_installer.sh

#### python.sh

**責務**: Python仮想環境管理

**関数**:
- `python_create_venv(venv_path)`: venv作成
- `python_activate_venv(venv_path)`: venv有効化
- `python_install_packages(venv_path, requirements_file)`: パッケージインストール
- `python_verify_activation()`: 有効化検証

**使用箇所**: reforge.sh, reforge_config.sh, reforge_ui_config.sh

#### link_helper.sh

**責務**: シンボリックリンク管理

**関数**:
- `check_source_path(path)`: ソースパス検証
- `check_dest_directory(path)`: 宛先ディレクトリ検証
- `handle_existing_target(target)`: 既存ターゲット処理
- `create_symlink(source, target)`: シンボリックリンク作成
- `get_timestamp()`: タイムスタンプ取得
- `prompt_for_path()`: パス入力プロンプト
- `prompt_for_name()`: 名前入力プロンプト

**使用箇所**: reforge_link.sh, Model/*/link_input.sh, Model/*/link_output.sh

---

### 2. コアスクリプト（Core Scripts）

#### reforge.sh

**最重要スクリプト** - 環境セットアップの中核

**処理内容**:
1. Python 3.10.x 検証（厳密に 3.10、3.11 不可）
2. 仮想環境作成・有効化
3. PyTorchインストール（CUDA対応）
4. SageAttention, llama-cpp-python などの特殊ホイール
5. requirements.txt（198パッケージ）インストール
6. reForge サブモジュール初期化
7. 設定ファイルコピー

**依存関係**: github.sh, python.sh

**予想工数**: 30-40時間（最複雑）

#### reforge_extension.sh

**処理内容**:
- 13個のGitHub拡張機能を特定コミットでクローン
- 既存の非対応拡張機能をバックアップ
- 拡張機能設定ファイルコピー

**依存関係**: github.sh

#### reforge_link.sh

**処理内容**:
- 7つのモデルカテゴリのシンボリックリンク作成
- wildcards ディレクトリのリンク作成
- 出力ディレクトリのリンク作成

**依存関係**: link_helper.sh

---

### 3. ダウンロードシステム（Download System）

#### アーキテクチャパターン

**テンプレートベース自動生成**:

```
メタデータCSV
  ├─ スクリプト名
  ├─ モデルタイプ
  ├─ ダウンロード方法
  ├─ Civitai ID
  ├─ HuggingFace ID
  └─ 出力ディレクトリ
      ↓
  テンプレートエンジン
      ↓
  165+ .sh ファイル生成
```

#### ダウンロードヘルパー

| ヘルパー | 責務 | 依存スクリプト数 |
|---------|------|-----------------|
| civitai_download.sh | Civitai API | 66 |
| huggingface_download.sh | HuggingFace Models | 59 |
| civitai_download_unzip.sh | Civitai Zip | 21 |
| huggingface_hub_download.sh | HF Hub | 4 |
| aria_download.sh | 直接ダウンロード | 4 |
| recursive_call.sh | 再帰実行 | 13 |

---

## 設定管理

### バージョン管理型設定移行

**reforge_update_config.py**:

```python
# バージョンベースの設定移行
def migrate_config(current_version):
    if current_version < "1.5.0":
        update_1_5_0()
    if current_version < "2.0.0":
        update_2_0_0()
    # ...
```

**特徴**:
- 後方互換性確保
- 段階的な設定更新
- ユーザーデータ保護

### CSVドリブンプリセット

**styles.csv**:

```
名前,ネガティブプロンプト,プロンプト,サンプリング方法,CFGスケール,...
プリセット1,lowres bad,1girl,DPM++ 2M,7.0,...
```

**特徴**:
- コード変更不要
- UIに自動反映
- バックアップ自動作成

---

## モデル組織化

### シンボリックリンク構造

```
Model/Stable-diffusion/          # 実体モデル格納
  ├─ NoobE_v11.safetensors
  └─ AniKawa_v20.safetensors

stable-diffusion-webui-reForge/models/Stable-diffusion/
  └─ → (symlink) ../../Model/Stable-diffusion/
```

**利点**:
- ディスク容量節約
- モデル共有容易
- バックアップ簡素化

### LinkInput/LinkOutput

**LinkInput**: 外部ディレクトリをWebUIにリンク
**LinkOutput**: 出力先を外部ディレクトリにリンク

**使用例**:
```bash
bash Model/Stable-diffusion/link_input.sh /mnt/nas/models/
bash Model/Stable-diffusion/link_output.sh /mnt/ssd/outputs/
```

---

## 拡張機能管理

### 固定コミットによる再現性

```bash
# reforge_extension.sh
extensions=(
    "https://github.com/owner/repo1.git|abc123def456"
    "https://github.com/owner/repo2.git|def456abc789"
    # 13個の拡張機能
)
```

**利点**:
- バージョン固定で安定性確保
- 問題発生時のロールバック容易
- テスト済み環境の再現

---

## エラーハンドリング戦略

### 3段階エラーハンドリング

```bash
# レベル1: 厳密な構文チェック
set -euo pipefail

# レベル2: トラップによるクリーンアップ
trap 'echo "Error on line $LINENO"; exit 1' ERR

# レベル3: リトライロジック
retry() {
    local max_attempts=3
    for i in $(seq 1 $max_attempts); do
        if "$@"; then
            return 0
        fi
        sleep 2
    done
    return 1
}
```

---

## セキュリティ考慮事項

### 1. 入力検証

- すべてのユーザー入力を検証
- パスインジェクション防止
- クォートによるエスケープ

### 2. 権限管理

- root権限不要な設計
- ユーザーホームディレクトリ内で完結
- 適切なファイルパーミッション

### 3. ダウンロード検証

- HTTPS強制
- チェックサム検証（可能な場合）
- エラー時のクリーンアップ

---

## パフォーマンス最適化

### 1. 並列ダウンロード

```bash
# aria2c を使用した並列ダウンロード
aria_download() {
    aria2c -x 16 -s 16 "$url" -o "$output"
}
```

### 2. キャッシング戦略

- pip パッケージキャッシュ
- ダウンロード済みモデルスキップ
- Git クローンキャッシュ

### 3. 進捗表示

- ユーザーフィードバック向上
- タイムアウト設定
- 推定残り時間表示

---

## テスト戦略

### 単体テスト

```bash
# ヘルパー関数テスト
test_github_clone_or_pull() {
    local test_repo="https://github.com/test/repo.git"
    local test_dest="/tmp/test_repo"

    github_clone_or_pull "$test_repo" "$test_dest"
    assert_directory_exists "$test_dest"
    assert_git_repo "$test_dest"
}
```

### 統合テスト

```bash
# フルインストールテスト
integration_test() {
    bash easyreforge_installer.sh
    assert_webui_launches
    assert_model_generation_works
}
```

### ドライランモード

```bash
DRY_RUN=1 bash script.sh
# 実際のダウンロード・インストールなし
# ロジックのみ検証
```

---

## スケーラビリティ

### 新しいモデル追加

1. Download/カテゴリ/ に .sh スクリプト追加
2. メタデータCSV更新（自動生成の場合）
3. Download/All/ メタスクリプトが自動包含

### 新しい拡張機能追加

1. reforge_extension.sh にエントリ追加
2. コミットハッシュ指定
3. 設定ファイル追加（必要な場合）

### 新しいプラットフォーム

現在はUbuntu専用だが、将来的に他のLinuxディストリビューション対応も可能：

- Debian系: ほぼそのまま動作
- RedHat系: パッケージマネージャー調整
- Arch系: 依存関係調整

---

## まとめ

EasyReforge Ubuntuアーキテクチャは以下の原則に基づいています：

1. **モジュラー設計**: 各スクリプトが単一責務
2. **再利用性**: ヘルパーライブラリによる共通化
3. **自動化**: テンプレートベーススクリプト生成
4. **堅牢性**: 多層エラーハンドリング
5. **保守性**: 明確なディレクトリ構造とドキュメント

---

**作成日**: 2025-12-03
**バージョン**: 1.0
