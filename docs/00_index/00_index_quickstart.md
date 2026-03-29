# EasyReforge Ubuntu移行プロジェクト - プロジェクトガイド

**プロジェクト名**: EasyReforge Windows → Ubuntu 変換
**期間**: 10-12週間（フル実装）
**スコープ**: 237個の .bat ファイル → .sh ファイル
**状態**: 📋 計画完了・実装準備完了

---

## 🎯 プロジェクト目標

EasyReforge（Stable Diffusion WebUI reForge向けのターンキーインストーラー）を、**Windows限定から Ubuntu限定へ移行**します。

### 主な変更点
- ✅ 237個の Windowsバッチスクリプト（.bat）を Ubuntu シェルスクリプト（.sh）に変換
- ✅ 機能は変わらず、実装方法が Linux 対応に
- ✅ Python パッケージ（requirements.txt）はそのまま利用可能（ポータブル）

### 成功定義
- [ ] 全237スクリプト変換完了
- [ ] Ubuntu 20.04+ (Recommended: 24.04) で動作確認
- [ ] WebUI起動・画像生成動作
- [ ] モデルダウンロード機能動作
- [ ] シンボリックリンク機能動作
- [ ] 日本語UI完全対応（UTF-8）
- [ ] shellcheck 全スクリプト合格

---

## 📚 ドキュメント構成

本プロジェクトのドキュメントは以下のように構成されています：

### 1. **`.claude/CLAUDE.md`** ⭐ 最初にこれを読む
   - プロジェクト概要・アーキテクチャ
   - コア技術スタック（PyTorch, reForge, 198 Python packages）
   - アーキテクチャパターン
   - 7つの重要な警告（Cautions）
   - 実装期間全体での参照用

   **対象**: 誰もが読むべき

### 2. **`UBUNTU_MIGRATION_PLAN.md`** 📋 次にこれを読む
   - 包括的な実装計画（10-12週間）
   - 5つのフェーズ詳細（Phase 1-5）
   - Shell-scripting スキルの活用方法
   - 依存関係グラフ
   - テスト戦略

   **対象**: プロジェクト管理者・計画立案者

### 3. **`.claude/PHASE1_IMPLEMENTATION.md`** 🛠️ 実装前に読む
   - Phase 1（基盤スクリプト）の詳細手引き
   - Task 1-5 の ステップバイステップガイド
   - Shell-scripting スキルの実践例
   - トラブルシューティング

   **対象**: Phase 1 の実装者

### 4. **`.claude/IMPLEMENTATION_CHECKLIST.md`** ✅ 実装中に使う
   - 全5フェーズのチェックリスト
   - Task ごとの完了条件
   - Git コミット戦略
   - 進捗追跡方法

   **対象**: 実装開発者・プロジェクト管理者

### 5. **`SCRIPT_CONVERSION_REFERENCE.md`** 📖 参考資料
   - Windows batch → Ubuntu shell の変換テーブル
   - 70+ の変換パターン
   - エラーハンドリングパターン
   - よくある落とし穴

   **対象**: スクリプト変換者（参照用）

### 6. **`TODO.md`** (既存)
   - 高レベルな実装計画
   - Phase ごとの概要
   - スクリプト依存関係

   **対象**: 概要確認用

---

## 重要: 設計優先の開発プロセス

**バッチファイルの単純な構文置換は禁止です。**

各スクリプトを実装する前に、以下のプロセスに従ってください:

1. **バッチファイルの「目的」を理解する** - 何を達成しようとしているか
2. **EasyEnv/EasyTools のパターンを学ぶ** - 参考: `/home/ytsubame/src/_research_reference/ANALYSIS_REPORT.md`
3. **Ubuntu ネイティブな解決策を設計する** - apt でインストールされたツールを使う
4. **`Skill shell-scripting` を呼び出す** - プロフェッショナルな実装のため
5. **変換テーブルは構文確認のみに使う** - 主要参考資料としてではなく

**必須ドキュメント**:
- `.claude/CLAUDE.md` - Script Conversion Guidelines セクション
- `docs/../03_implementation/03_implementation_common_patterns.md` - Batch File Analysis Process
- `docs/../04_reference/04_reference_conversion_table.md` - 構文リファレンス（補助的に使用）

---

## クイックスタート

### シナリオ別ガイド

#### 📌 「このプロジェクト全体を理解したい」
1. `.claude/CLAUDE.md` を全て読む（30分）
2. `UBUNTU_MIGRATION_PLAN.md` を読む（30分）
3. `TODO.md` で概要確認（10分）

#### 🛠️ 「今すぐ実装を始めたい」
1. `.claude/CLAUDE.md` の「実装ガイドライン」セクション確認
2. `.claude/PHASE1_IMPLEMENTATION.md` で Task 1 開始
3. `.claude/IMPLEMENTATION_CHECKLIST.md` でチェック

#### 🔍 「特定のスクリプトを変換したい」
1. `SCRIPT_CONVERSION_REFERENCE.md` で変換パターン確認
2. 元の `.bat` ファイルを確認
3. シェル版を実装・テスト

#### 🐛 「トラブルシューティングが必要」
1. `.claude/PHASE1_IMPLEMENTATION.md` の「よくある問題」参照
2. `CLAUDE.md` の「Critical Cautions」参照
3. `SCRIPT_CONVERSION_REFERENCE.md` の「よくある落とし穴」参照

---

## 📋 実装フローチャート

```
START
  │
  ├─→ Read: .claude/CLAUDE.md (全員必須)
  │     └─→ Understand: Project scope, architecture, cautions
  │
  ├─→ Phase 1: Foundation Scripts (1-2 weeks)
  │     ├─→ Task 1.1: Implement github.sh
  │     ├─→ Task 1.2: Implement uv.sh
  │     ├─→ Task 1.3: Convert easyreforge_installer.sh
  │     ├─→ Task 1.4: Convert update.sh
  │     ├─→ Task 1.5: Convert setup.sh
  │     └─→ Integration Test 1.1-1.2
  │
  ├─→ Phase 2: Core Environment (3-4 weeks)
  │     ├─→ Task 2.1: Implement reforge.sh (CRITICAL - 40-50h)
  │     ├─→ Task 2.2: Convert reforge_extension.sh
  │     ├─→ Task 2.3: Convert reforge_link.sh
  │     ├─→ Task 2.4-2.6: Convert config scripts
  │     └─→ Integration Test 2.1-2.3
  │
  ├─→ Phase 2b: Model Linking (Parallel, 9-10 weeks)
  │     ├─→ Task 2b.1: Implement link_helper.sh
  │     ├─→ Task 2b.2-2.4: Create symlink templates
  │     └─→ Integration Test 2b
  │
  ├─→ Phase 3: Download Helpers (5-6 weeks)
  │     ├─→ Task 3.1-3.7: Implement 7 helper libraries
  │     ├─→ Task 3.8: Extract metadata CSV
  │     └─→ Integration Test 3
  │
  ├─→ Phase 4: Model Script Generation (7-8 weeks)
  │     ├─→ Task 4.1: Auto-generate 165+ scripts
  │     ├─→ Task 4.2-4.3: Convert meta-scripts
  │     ├─→ Task 4.4-4.5: Validate & test
  │     └─→ Integration Test 4
  │
  ├─→ Phase 5: Optional & QA (11-12 weeks)
  │     ├─→ Task 5.1-5.2: Convert launchers
  │     ├─→ Integration Test 5.1-5.3: Ubuntu 24.04 (Primary Focus)
  │     ├─→ Task 5.3-5.4: Documentation & release
  │     └─→ All tests PASS
  │
  └─→ END: Release Complete ✅
```

---

## 📊 プロジェクト構成

```
EasyReforge-Ubuntu/
├── .claude/                          # ← ドキュメント
│   ├── CLAUDE.md                     # プロジェクト基本仕様
│   ├── PHASE1_IMPLEMENTATION.md      # Phase 1 詳細手引き
│   ├── IMPLEMENTATION_CHECKLIST.md   # チェックリスト
│   └── README.md                     # このファイル
│
├── EasyReforge/                      # メイン実装（23 .bat → .sh）
│   ├── easyreforge_installer.sh      # Phase 1
│   ├── setup.sh                      # Phase 1
│   ├── update.sh                     # Phase 1
│   │
│   ├── src/
│   │   ├── lib/
│   │   │   ├── github.sh             # Phase 1 Helper
│   │   │   └── uv.sh                 # Phase 1 Helper
│   │   ├── requirements.txt          # NO CONVERSION
│   │   ├── reforge_update_config.py  # NO CONVERSION
│   │   ├── styles.csv                # NO CONVERSION
│   │   └── stable-diffusion-webui-reForge/ # Git submodule
│   │
│   └── Reforge/                      # PRIMARY FOCUS
│       ├── reforge.sh                # Phase 2 CRITICAL
│       ├── reforge_extension.sh      # Phase 2
│       ├── reforge_link.sh           # Phase 2
│       ├── reforge_config.sh         # Phase 2
│       ├── reforge_ui_config.sh      # Phase 2
│       └── Reforge_NoOptions.sh      # Phase 2
│
├── Download/                         # Model downloads (176 .bat → .sh)
│   ├── lib/                          # Phase 3 Helpers
│   │   ├── common.sh
│   │   ├── civitai_download.sh       # 66 scripts depend
│   │   ├── huggingface_download.sh   # 59 scripts depend
│   │   ├── civitai_download_unzip.sh # 21 scripts depend
│   │   ├── huggingface_hub_download.sh
│   │   ├── aria_download.sh
│   │   └── recursive_call.sh
│   │
│   ├── Stable-diffusion/            # Phase 4 Auto-generated
│   ├── Lora/
│   ├── ControlNet/
│   ├── ESRGAN/, VAE/, adetailer/, wildcards/
│   └── All/                          # Meta-scripts
│
├── Model/                            # Linking scripts (Phase 2b)
│   ├── Stable-diffusion/
│   ├── Lora/
│   ├── ControlNet/
│   └── ...
│
├── UBUNTU_MIGRATION_PLAN.md          # 実装計画（このディレクトリ）
├── SCRIPT_CONVERSION_REFERENCE.md    # 変換リファレンス
├── TODO.md                           # 高レベル計画
└── CLAUDE.md (existing)              # 既存プロジェクト仕様
```

---

## ⚙️ 技術スタック

### 核となるツール
- **Bash 4.0+** - シェルスクリプト実行環境
- **Git 2.25+** - バージョン管理・リポジトリ操作
- **uv (Python 3.10+)** - Python 仮想環境およびパッケージ管理
- **CUDA 12.8** - GPU 計算（オプション）
- **PyTorch 2.7.1** - ディープラーニング
- **reForge** - Stable Diffusion WebUI

### 変換スキルセット
- **Shell-scripting** - Bash スクリプト設計パターン
  - エラーハンドリング（set -euo pipefail, trap）
  - ファイル操作と検証
  - 外部コマンド実行制御
  - 環境変数管理
  - テキスト処理（grep, sed, awk）
  - 関数設計と再利用

### 検証ツール
- **ShellCheck** - Bash 文法・スタイル検証
- **Git** - バージョン管理・進捗追跡

---

## 🔑 重要な概念

### 1. 依存関係の重要性
```
Phase 1（基盤） → Phase 2（コア） → Phase 3-4（モデル）
```
Phase 1 なしに Phase 2 は始められません。

### 2. Critical Path: reforge.sh
```
最複雑スクリプト: reforge.sh (40-50 時間)
├─ PyTorch インストール（プラットフォーム固有）
├─ 仮想環境管理
├─ 要件ファイル処理
└─ 環境変数設定
```

### 3. 自動化の活用
```
Phase 4 では 165+ スクリプトをテンプレートから自動生成
→ メタデータ CSV + テンプレート = スクリプト
```

### 4. テスト戦略
```
各 Phase 完了時：
1. shellcheck で文法検証
2. 手動テスト実行
3. 統合テスト実施
4. Ubuntu 24.04 でテスト確認 (Benchmark)
```

---

## 🎓 学習リソース

### Shell-Scripting パターン
1. **エラーハンドリング**
   ```bash
   set -euo pipefail
   trap 'echo "Error on line $LINENO"; exit 1' ERR
   ```

2. **関数テンプレート**
   ```bash
   function_name() {
       local param="$1"
       # validation
       # implementation
       return 0  # or 1 on error
   }
   ```

3. **ファイル操作**
   ```bash
   [ -f "$file" ] && echo "exists" || echo "missing"
   [ -d "$dir" ] || mkdir -p "$dir"
   [ -L "$symlink" ] && target=$(readlink "$symlink")
   ```

### Batch → Shell 変換テンプレート
```batch
REM Windows Batch
set VAR=value
%VAR%
call script.bat
if exist path (...)

→

#!/bin/bash
VAR=value
"$VAR"
bash script.sh
[ -e path ] && ...
```

詳細は `SCRIPT_CONVERSION_REFERENCE.md` を参照

---

## 👥 ロール別ガイド

### プロジェクト管理者
1. `.claude/CLAUDE.md` 読了
2. `UBUNTU_MIGRATION_PLAN.md` で全体像把握
3. `.claude/IMPLEMENTATION_CHECKLIST.md` で進捗管理
4. 週次進捗レビュー

### Phase 1-2 実装者（基盤・コア）
1. `.claude/CLAUDE.md` 「実装ガイドライン」セクション確認
2. `.claude/PHASE1_IMPLEMENTATION.md` で Task 実施
3. `SCRIPT_CONVERSION_REFERENCE.md` で変換パターン参照
4. `.claude/IMPLEMENTATION_CHECKLIST.md` でチェック

### Phase 3-4 実装者（モデル・自動化）
1. `UBUNTU_MIGRATION_PLAN.md` の Phase 3-4 セクション確認
2. `SCRIPT_CONVERSION_REFERENCE.md` で変換パターン参照
3. メタデータ CSV 形式を理解
4. テンプレート エンジン設計を確認

### QA / テスター
1. `.claude/IMPLEMENTATION_CHECKLIST.md` の Integration Test セクション
2. `CLAUDE.md` のテスト戦略セクション
3. 複数 Ubuntu バージョンでのテスト実施
4. バグレポート作成

---

## 🚨 Critical Items

⚠️ 以下は **絶対に失敗できない** 重要項目です：

### 1. **reforge.sh の PyTorch インストール**
   - GPU 検出の正確さ
   - 正しいホイール選択
   - フォールバック戦略

### 2. **Git サブモジュール管理**
   - reForge 側の安定性
   - 拡張機能のコミット固定

### 3. **シンボリックリンク動作**
   - Windows junctions → Linux symlinks 変換
   - Python での symlink 走査

### 4. **UTF-8 ローカライゼーション**
   - 日本語 UI 表示
   - `export LC_ALL=C.UTF-8`

---

## 📞 困ったときは

### Step 1: ドキュメント確認
1. `.claude/PHASE1_IMPLEMENTATION.md` の「よくある問題」
2. `CLAUDE.md` の「Critical Cautions」
3. `SCRIPT_CONVERSION_REFERENCE.md` の「よくある落とし穴」

### Step 2: 検索
- grep で既存スクリプトから類似パターンを探す
- GitHub Issues で類似の問題を検索

### Step 3: テスト・デバッグ
```bash
# デバッグモード
bash -x script.sh  # トレース表示

# 構文チェック
shellcheck script.sh

# ドライラン
DRY_RUN=1 bash script.sh
```

---

## 📈 進捗追跡

### 推奨方法
1. **`.claude/IMPLEMENTATION_CHECKLIST.md`** を Git で管理
   - 各 Task ごとに [ ] → [x] に更新
   - Git commit で履歴保持

2. **Weekly Review**
   - 完了 Task 数
   - ブロッカー確認
   - Phase 予測時間との比較

3. **GitHub Projects / Issues**（オプション）
   - Kanban ボードで可視化
   - Task 間の依存関係表示

---

## ✅ 成功の指標

### Phase 1 完了
- [ ] 5つのスクリプト実装完了
- [ ] すべて shellcheck 合格
- [ ] 統合テスト合格

### Phase 2 完了
- [ ] reforge.sh で WebUI 起動可能
- [ ] GPU/CPU の両対応確認

### Phase 3 完了
- [ ] 7つのヘルパー完成
- [ ] メタデータ CSV 生成完了

### Phase 4 完了
- [ ] 165+ スクリプト自動生成完了
- [ ] すべて shellcheck 合格

### 全体完了
- [ ] 237 全スクリプト変換完了
- [ ] Ubuntu 24.04 でテスト合格 (Primary Benchmark)
- [ ] ドキュメント完成
- [ ] リリース準備完了

---

## 📅 タイムライン

| 週 | フェーズ | 主要成果物 |
|----|---------|----------|
| 1-2 | Phase 1 | github.sh, uv.sh, easyreforge_installer.sh |
| 3-4 | Phase 2 | **reforge.sh** (CRITICAL), reforge_extension.sh |
| 5-6 | Phase 3 | 7つのダウンロード helper, メタデータ CSV |
| 7-8 | Phase 4 | 165+ モデルスクリプト（自動生成） |
| 9-10 | Phase 2b | モデルリンキング スクリプト |
| 11-12 | Phase 5 | ランチャー, QA, リリース |

---

## 🎯 Next Steps

### 🚀 今すぐ開始
1. `.claude/CLAUDE.md` を完全に読む（45分）
2. `UBUNTU_MIGRATION_PLAN.md` を読む（30分）
3. `.claude/PHASE1_IMPLEMENTATION.md` で Task 1.1 開始

### 📋 準備作業
- [ ] 開発環境の確認（Git, Bash, uv / Python 3.10+）
- [ ] 元の EasyReforge Windows 版を確認
- [ ] ShellCheck インストール（推奨）

### ⚡ 実装開始
- [ ] `.claude/IMPLEMENTATION_CHECKLIST.md` を準備
- [ ] Phase 1 Task 1.1 実装
- [ ] Git branch で作業開始

---

## 📄 ドキュメントメンテナンス

これらのドキュメントは「生きたドキュメント」です。
実装過程で発見した内容は適宜更新してください：

- 新しい落とし穴発見 → `SCRIPT_CONVERSION_REFERENCE.md` に追加
- Phase ごとのレッスン → `.claude/PHASE1_IMPLEMENTATION.md` に追加
- チェックリスト修正 → `.claude/IMPLEMENTATION_CHECKLIST.md` を更新
- 重要なお知らせ → `.claude/CLAUDE.md` の Critical Cautions に追加

---

## 📝 更新履歴

| 日付 | 更新内容 | 作成者 |
|------|---------|--------|
| 2025-12-03 | 初期ドキュメント作成 | Planning Team |
| - | Phase 1 実装開始予定 | - |

---

**版**: 1.0
**最終更新**: 2025-12-03
**ステータス**: ✅ 実装準備完了

**次フェーズ**: Phase 1 Task 1.1 開始予定

---

## 📞 クイックリファレンス

```bash
# ドキュメント一覧
cat .claude/CLAUDE.md                    # プロジェクト仕様
cat UBUNTU_MIGRATION_PLAN.md            # 実装計画
cat .claude/PHASE1_IMPLEMENTATION.md    # Phase 1 手引き
cat .claude/IMPLEMENTATION_CHECKLIST.md # チェックリスト

# 開発環境確認
git --version && bash --version && uv --version

# Shellcheck インストール
sudo apt-get install shellcheck

# 初回実行（テスト）
bash EasyReforge/src/lib/github.sh --help

# Git 設定
git config user.name "Your Name"
git config user.email "your@example.com"
git checkout -b ubuntu-migration
```

---

プロジェクトへようこそ！お疲れ様です。

