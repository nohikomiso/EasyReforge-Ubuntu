# EasyReforge Ubuntu移行 - 実装チェックリスト

**目的**: 計画的で追跡可能な実装を実現
**対象**: プロジェクト管理者・実装開発者

---

## Phase 1: 基盤スクリプト変換 (Weeks 1-2)

**⚠️ 【重要】実装時は必ず [03_implementation_phase1.md](../03_implementation/03_implementation_phase1.md) の詳細要件とコードパターンを熟読してから作業を開始すること！**

### ヘルパーライブラリ作成

- [x] **Task 1.1**: `EasyReforge/src/lib/github.sh` 作成
  - [x] `github_clone_or_pull()` 関数実装
  - [x] `github_fetch_commit()` 関数実装
  - [x] `github_verify_clone()` 関数実装
  - [x] shellcheck 合格
  - [x] 手動テスト合格
  - [x] Git を追加・コミット

- [x] **Task 1.2**: `EasyReforge/src/lib/uv.sh` 作成
  - [x] `uv_create_venv()` 関数実装
  - [x] `uv_activate_venv()` 関数実装
  - [x] `uv_install_packages()` 関数実装
  - [x] `uv_verify_activation()` 関数実装
  - [x] shellcheck 合格
  - [x] 手動テスト合格
  - [x] Git を追加・コミット

### メインスクリプト変換

- [x] **Task 1.3**: `EasyReforge/easyreforge_installer.sh` 変換
  - [x] 元の `.bat` ファイルを確認
  - [x] Windows固有コード（PowerShell, レジストリ）を除去
  - [x] Ubuntu固有コード（git, bash, UTF-8）を追加
  - [x] github.sh と python.sh をインポート
  - [x] shellcheck 合格
  - [x] dry-run でテスト
  - [x] Git を追加・コミット

- [x] **Task 1.4**: `EasyReforge/update.sh` 変換
  - [x] 元の `Update.bat` を確認
  - [x] リポジトリ更新ロジックを変換
  - [x] shellcheck 合格
  - [x] テスト実行
  - [x] Git を追加・コミット

- [x] **Task 1.5**: `EasyReforge/setup.sh` 変換
  - [x] 元の `Setup.bat` を確認
  - [x] バリアント選択ロジックを変換
  - [x] shellcheck 合格
  - [x] テスト実行
  - [x] Git を追加・コミット

### Phase 1 統合テスト

- [x] **Integration Test 1.1**: ヘルパーライブラリの相互動作
  - [x] github.sh でリポジトリ(https://github.com/nohikomiso/EasyReforge-Ubuntu.git)ubuntu-migrationブランチをクローン
  - [x] uv.sh で uv venv を作成・有効化
  - [x] 連続実行テスト成功

- [x] **Integration Test 1.2**: easyreforge_installer.sh の完全実行
  - [x] スクリプト実行開始
  - [x] 環境チェック合格
  - [x] EasyTools クローン成功
  - [x] setup.sh 呼び出し成功
  - [x] エラーなく完了

- [x] **Documentation**: Phase 1 完了ドキュメント
  - [x] CLAUDE.md更新（廃止済みのため `RELEASE_NOTES_Phase1.md` 作成にて代替完了）
  - [x] リリースノート作成

---

## Phase 2: コア環境構築変換 (Weeks 3-4)

**⚠️ 【重要】実装時は必ず [03_implementation_phase2.md](../03_implementation/03_implementation_phase2.md) の詳細要件とコードパターンを熟読してから作業を開始すること！**

### Critical: reforge.sh 実装

- [x] **Task 2.1**: `EasyReforge/Reforge/reforge.sh` 実装（CRITICAL）
  - [x] 環境検証セクション
    - [x] uv 要求検証 (Python 3.10環境はuvが自動構築)
    - [x] NVIDIA GPU 検出（オプション）
    - [x] CUDA Toolkit 確認（GPU使用時）
    - [x] 20GB+ 空きディスク確認

  - [x] uv venv セットアップ
    - [x] lib/python.sh で uv プロジェクト・仮想環境作成
    - [x] venv有効化検証

  - [x] PyTorch インストール
    - [x] GPU検出ロジック実装
    - [x] 正しいホイール決定アルゴリズム
    - [x] ホイールダウンロード実装
    - [x] フォールバック処理（ソースビルド）

  - [x] 要件ファイルインストール
    - [x] requirements.txt パース
    - [x] uv pip install 実行
    - [x] エラーハンドリング
    - [x] キャッシング戦略実装

  - [x] 環境変数セットアップ
    - [x] CUDA関連環境変数設定
    - [x] メモリ管理設定

  - [x] WebUI初期化
    - [x] submodule初期化
    - [x] reForge準備完了確認

  - [x] shellcheck 合格
  - [x] 実際のGPUで起動テスト
  - [x] GPU非搭載環境での起動テスト（CPU-only）

- [x] **Task 2.2**: `EasyReforge/Reforge/reforge_extension.sh` 実装
  - [x] 13個の拡張機能定義
  - [x] 各拡張機能のクローンロジック
  - [x] コミットハッシュ指定処理
  - [x] エラーハンドリング
  - [x] shellcheck 合格
  - [x] 各拡張機能の起動確認

- [x] **Task 2.3**: `EasyReforge/Reforge/reforge_link.sh` 実装
  - [x] シンボリックリンク作成関数
  - [x] Windows junctionからのコンバート
  - [x] ln -s による実装
  - [x] symlink検証処理
  - [x] shellcheck 合格
  - [x] WebUIがsymlink経由でモデル読み込み確認

- [x] **Task 2.4**: `EasyReforge/Reforge/reforge_config.sh` 実装
  - [x] reforge_update_config.py 呼び出し
  - [x] 後方互換性処理
  - [x] エラーハンドリング
  - [x] shellcheck 合格

- [x] **Task 2.5**: `EasyReforge/Reforge/reforge_ui_config.sh` 実装
  - [x] reforge_update_ui-config.py 呼び出し
  - [x] UI設定の移行
  - [x] styles.csv 管理
  - [x] shellcheck 合格

- [x] **Task 2.6**: Root Launcher `EasyReforge/reforge.sh` 実装
  - [x] WebUI起動スクリプト
  - [x] Reforge/reforge.sh からの呼び出し
  - [x] ログ出力
  - [x] エラーハンドリング

### Phase 2 統合テスト

- [x] **Integration Test 2.1**: reforge.sh のフル実行 (E2Eテスト済)
  - [x] 環境検証
  - [x] uv venv 作成
  - [x] PyTorch インストール
  - [x] 要件パッケージインストール
  - [x] WebUI初期化
  - [x] エラーなく完了

- [ ] **Integration Test 2.2**: WebUI起動テスト
  - [x] bash reforge.sh で起動 (初期化と引数パースまで確認)
  - [ ] localhost:7860 にアクセス可能 (Phase 3実装後)
  - [ ] UI表示正常 (Phase 3実装後)
  - [ ] 画像生成テスト実行 (Phase 3実装後)
  - [ ] 処理完了

- [ ] **Integration Test 2.3**: 複数GPU環境テスト
  - [ ] GPU1での起動
  - [ ] GPU2への切り替え
  - [ ] GPU設定が反映されることを確認

- [ ] **Documentation**: Phase 2 完了ドキュメント
  - [ ] CLAUDE.md の「Phase 2」セクション更新
  - [ ] トラブルシューティングガイド作成

---

## Phase 2b: モデルリンク変換 (Weeks 9-10)

**⚠️ 【重要】実装時は必ず相関するリンクロジックパターン（[03_implementation_phase2.md](../03_implementation/03_implementation_phase2.md) 等）を熟読してから作業を開始すること！**

- [x] **Task 2b.1**: `EasyReforge/Reforge/src/link_helper.sh` 実装
  - [x] 全7つのリンク関数実装
  - [x] symlink作成
  - [x] 検証処理
  - [x] shellcheck 合格

- [x] **Task 2b.2**: `Model/Stable-diffusion/link_input.sh` 実装
  - [x] テンプレート作成
  - [x] 手動テスト

- [x] **Task 2b.3**: `Model/Stable-diffusion/link_output.sh` 実装
  - [x] テンプレート作成
  - [x] 手動テスト

- [x] **Task 2b.4**: テンプレート複製
  - [x] `Model/Lora/` に複製
  - [x] `Model/ControlNet/` に複製
  - [x] `Model/VAE/` に複製
  - [x] `Model/ESRGAN/` に複製
  - [x] `Model/adetailer/` に複製
  - [x] `Model/wildcards/` に複製

- [x] **Integration Test 2b**: Symlink動作テスト
  - [x] link_input.sh で外部ディレクトリをリンク
  - [x] link_output.sh で出力ディレクトリをリンク
  - [x] WebUIから読み込み可能か確認
  - [x] Python での symlink 走査確認

---

## Phase 3: ダウンロードヘルパー変換 (Weeks 5-6)

**⚠️ 【重要】実装時は必ず [03_implementation_phase3.md](../03_implementation/03_implementation_phase3.md) の詳細要件とコードパターンを熟読してから作業を開始すること！**

### ヘルパーライブラリ実装

- [x] **Task 3.1**: `Download/lib/common.sh` 実装
  - [x] `log_info()` 関数
  - [x] `log_error()` 関数
  - [x] `download_with_retry()` 関数
  - [x] `extract_filename_from_url()` 関数
  - [x] `validate_file_integrity()` 関数
  - [x] shellcheck 合格
  - [x] ユニットテスト実行

- [x] **Task 3.2**: `Download/lib/civitai_download.sh` 実装
  - [x] Civitai API認証
  - [x] `civitai_download()` 関数
  - [x] `civitai_get_download_url()` 関数
  - [x] `civitai_verify_api_key()` 関数
  - [x] レート制限対応
  - [x] エラーハンドリング
  - [x] shellcheck 合格
  - [x] API テスト

- [x] **Task 3.3**: `Download/lib/huggingface_download.sh` 実装
  - [x] HF Hub APIサポート
  - [x] `huggingface_download()` 関数
  - [x] `huggingface_list_files()` 関数
  - [x] エラーハンドリング
  - [x] shellcheck 合格
  - [x] API テスト

- [x] **Task 3.4**: `Download/lib/civitai_download_unzip.sh` 実装
  - [x] Zipダウンロード処理
  - [x] 解凍ロジック
  - [x] エラーハンドリング
  - [x] shellcheck 合格

- [x] **Task 3.5**: `Download/lib/huggingface_hub_download.sh` 実装
  - [x] HF Hub-CLI 統合
  - [x] shellcheck 合格

- [x] **Task 3.6**: `Download/lib/aria_download.sh` 実装
  - [x] aria2c による直接ダウンロード
  - [x] マルチスレッド対応
  - [x] shellcheck 合格

- [x] **Task 3.7**: `Download/lib/recursive_call.sh` 実装
  - [x] ディレクトリ再帰処理
  - [x] shellcheck 合格

### メタデータ抽出

- [ ] **Task 3.8**: メタデータ抽出ツール実装
  - [ ] 176個の .bat ファイル解析
  - [ ] CSV メタデータ生成
  - [ ] CSV バリデーション
  - [ ] 欠落データ確認

- [ ] **Integration Test 3**: ダウンロードヘルパーテスト
  - [ ] 各ヘルパーの基本動作確認
  - [ ] Civitai API テスト
  - [ ] HuggingFace API テスト
  - [ ] エラーハンドリング確認

---

## Phase 4: モデル・拡張スクリプト変換 (Weeks 7-8)

**⚠️ 【重要】実装時は必ず [03_implementation_phase4.md](../03_implementation/03_implementation_phase4.md) の詳細要件とコードパターンを熟読してから作業を開始すること！**

### 自動生成

- [ ] **Task 4.1**: スクリプト生成ツール実装
  - [ ] メタデータCSV読み込み
  - [ ] テンプレートエンジン実装
  - [ ] 165+ スクリプト生成
  - [ ] 生成スクリプトファイルへの書き込み

- [ ] **Task 4.2**: メタスクリプト変換
  - [ ] 20個の「All」スクリプト変換
  - [ ] recursive_call を使用
  - [ ] 正常に子スクリプトを呼び出し確認

- [ ] **Task 4.3**: 構成スクリプト変換
  - [ ] 2個の構成スクリプト手動変換

### 検証と最適化

- [ ] **Task 4.4**: Shellcheck検証
  - [ ] すべての生成スクリプトを検証
  - [ ] エラー修正
  - [ ] 合格確認

- [ ] **Task 4.5**: ドライランテスト
  - [ ] DRY_RUN=1 で実行
  - [ ] 各スクリプトが正常に終了
  - [ ] ダウンロード処理がシミュレートされる

- [ ] **Integration Test 4**: メタスクリプト動作テスト
  - [ ] Download/All/AllStable-diffusion.sh 実行
  - [ ] すべての子スクリプトが呼ばれる
  - [ ] エラーなく完了

---

## Phase 5: オプションランチャー変換 (Weeks 11-12)

**⚠️ 【重要】実装時は必ず [03_implementation_phase5.md](../03_implementation/03_implementation_phase5.md) の詳細要件とコードパターンを熟読してから作業を開始すること！**

### ランチャースクリプト

- [ ] **Task 5.1**: Reforge ランチャー変換
  - [ ] `reforge_gpu.sh` 変換
  - [ ] `reforge_cpu.sh` 変換
  - [ ] その他バリアント変換（6個）
  - [ ] shellcheck 合格
  - [ ] 実行テスト

- [ ] **Task 5.2**: LLM推論スクリプト変換
  - [ ] 8個の LLM スクリプト変換
  - [ ] shellcheck 合格
  - [ ] 実行テスト

### エンドツーエンドテスト

- [ ] **Integration Test 5.1**: Ubuntu 18.04 での完全テスト
  - [ ] インストール実行
  - [ ] WebUI起動
  - [ ] 画像生成テスト
  - [ ] モデルダウンロード
  - [ ] 全機能テスト合格

- [ ] **Integration Test 5.2**: Ubuntu 20.04 での完全テスト
  - [ ] 上記と同じテスト実施

- [ ] **Integration Test 5.3**: Ubuntu 22.04 での完全テスト
  - [ ] 上記と同じテスト実施

### ドキュメント・リリース

- [ ] **Task 5.3**: ドキュメント完成
  - [ ] CLAUDE.md 最終更新
  - [ ] README.md 作成（セットアップ手順）
  - [ ] トラブルシューティングガイド
  - [ ] ユーザーマニュアル

- [ ] **Task 5.4**: リリース準備
  - [ ] CHANGELOG 作成
  - [ ] リリースノート作成
  - [ ] タグ付けと公開準備

---

## 成功条件チェック

最終的に以下をすべて確認：

- [ ] 全237個のバッチファイルが .sh に変換
- [ ] すべてのスクリプトが shellcheck 合格
- [ ] Ubuntu 18.04+ で動作確認
- [ ] WebUI が起動・画像生成が可能
- [ ] モデルダウンロード機能が動作
- [ ] シンボリックリンク機能が動作
- [ ] 日本語UI が完全機能
- [ ] ドキュメント完成
- [ ] リリース準備完了

---

## Git コミット戦略

各 Task 完了時：

```bash
# 例: Task 1.1 完了
git add EasyReforge/src/lib/github.sh
git commit -m "Phase 1 Task 1.1: Implement github.sh helper library"

# 例: Phase 1 統合テスト合格
git add -A
git commit -m "Phase 1 Complete: Foundation scripts and helpers

- Implement github.sh (clone/pull/verify)
- Implement python.sh (venv management)
- Convert easyreforge_installer.sh
- Convert update.sh
- Convert setup.sh
- All scripts pass shellcheck
- Integration tests pass

See UBUNTU_MIGRATION_PLAN.md for details."
```

---

## 進捗追跡方法

**毎週確認**:
- [ ] 予定されたタスク完了数
- [ ] shellcheck エラー数
- [ ] テスト合格数
- [ ] コミット数

**毎日確認**:
- [ ] 本日のタスク進捗
- [ ] ブロッカー確認
- [ ] ドキュメント更新

---

## よくある遅延要因と対策

| 遅延要因 | 予防策 |
|---------|------|
| PyTorch インストール失敗 | 事前にGPU環境構築、ホイール可用性確認 |
| Git サブモジュール問題 | github.sh の十分なテスト |
| 環境依存問題 | 複数Ubuntu バージョンでのテスト |
| APIレート制限 | リトライロジック、遅延設定の実装 |
| ネットワークエラー | エラーハンドリング、フォールバック実装 |

---

**最終更新**: 2025-12-03
**ステータス**: チェックリスト完成・実装準備完了
**次ステップ**: Phase 1 Task 1.1 開始

