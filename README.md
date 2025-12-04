# EasyReforge Ubuntu Migration 🚀

**Ubuntu 向け reForge WebUI インストーラー**

> ⚠️ **本リポジトリは Ubuntu マイグレーション進行中です**
>
> このリポジトリは、Windows 版 EasyReforge から Ubuntu 専用版への移行作業が進行中です。
> 実装状況については下記の「プロジェクトステータス」セクションを参照してください。

---

## 現在の開発状況

| ステータス | 説明 |
|-----------|------|
| **現在のブランチ** | `ubuntu-migration` （デフォルト開発ブランチ） |
| **メインブランチ** | `main` （リリース版用） |
| **実装フェーズ** | Phase 0 ✅ 完了 → Phase 1 準備中 |
| **進捗** | 分析完了、実装開始待機中 |

---

## 概要

EasyReforge Ubuntu は、[reForge WebUI](https://github.com/Panchovix/stable-diffusion-webui-reForge)（Stable Diffusion 画像生成）の Ubuntu 環境向けインストーラーです。

元の [Windows 版 EasyReforge](https://github.com/Zuntan03/EasyReforge) をフルスクラッチで Ubuntu 専用に移行しています。

### マイグレーションの特徴

- 📋 **237個の Windows .bat ファイル** → **Ubuntu .sh スクリプト** への全面移行
- 🔄 **10-12週間の段階的実装計画** （詳細は下記参照）
- 📊 **Phase 0 分析完了** - Windows インストーラー完全解析済み
- 🛠️ **実装ガイド完備** - 段階的な開発手順を文書化

---

## プロジェクト構造

```
EasyReforge-Ubuntu/
├── docs/                                    # 📚 ドキュメント
│   ├── 00_index_master.md                  # マスターナビゲーション ⭐
│   ├── 00_index_quickstart.md              # クイックスタート
│   ├── 00_index_architecture.md            # アーキテクチャ概要
│   │
│   ├── 01_analysis_overview.md             # Phase 0: 分析概要 ✅
│   ├── 01_analysis_summary.md              # Phase 0: 要約
│   ├── 01_analysis_technical.md            # Phase 0: 技術リファレンス
│   ├── 01_analysis_detailed.md             # Phase 0: フロー図と詳細分析
│   │
│   ├── 02_planning_overview.md             # 計画・概要（日本語）
│   ├── 02_planning_phases.md               # フェーズ1-5と全スクリプトインベントリ
│   │
│   ├── 03_implementation_common_patterns.md # 実装ガイド（メイン） ⭐
│   ├── 03_implementation_phase1.md         # Phase 1 詳細
│   ├── 03_implementation_phase2.md         # Phase 2 詳細（CRITICAL）
│   ├── 03_implementation_phase3.md         # Phase 3 詳細
│   ├── 03_implementation_phase4.md         # Phase 4 詳細
│   ├── 03_implementation_phase5.md         # Phase 5 詳細
│   │
│   ├── 04_reference_conversion_table.md    # コマンド変換テーブル
│   ├── 04_reference_checklist.md           # テスト・検証チェックリスト
│   ├── 04_reference_known_issues.md        # 既知の問題と対策
│   └── 04_reference_troubleshooting.md     # トラブルシューティング
│
├── EasyReforge/                             # メインインストール（23 .bat → .sh）
│   ├── Reforge/                            # reForge バリアント
│   │   ├── reforge.sh                      # [PHASE 2 - CRITICAL]
│   │   ├── reforge_extension.sh
│   │   ├── reforge_link.sh
│   │   ├── src/
│   │   │   ├── requirements.txt            # 198 Python パッケージ
│   │   │   ├── lib/
│   │   │   │   ├── github.sh
│   │   │   │   └── python.sh
│   │   │   └── stable-diffusion-webui-reForge/  # Git submodule
│   │   └── Reforge_NoOptions.sh            # [PHASE 2]
│   ├── A1111/                              # Automatic1111 バリアント
│   └── Forge/                              # Forge バリアント
│
├── Download/                                # モデルダウンロード（176 .bat → .sh）[PHASE 3-4]
│   ├── lib/                                # ダウンロードヘルパー
│   │   ├── common.sh
│   │   ├── civitai_download.sh
│   │   ├── huggingface_download.sh
│   │   └── ...（4つ追加）
│   ├── Stable-diffusion/                   # 48 スクリプト [PHASE 4]
│   ├── Lora/                               # 36 スクリプト [PHASE 4]
│   ├── ControlNet/                         # 27 スクリプト [PHASE 4]
│   └── All/                                # メタスクリプト [PHASE 4]
│
├── Model/                                   # シンボリックリンク（14 .bat → .sh）[PHASE 2b]
│   └── Stable-diffusion/
│       ├── link_input.sh
│       └── link_output.sh
│
├── Llm/                                     # LLM 推論（8 .bat → .sh）[PHASE 5]
├── Sample/                                  # デモスクリプト [PHASE 5]
│
├── .claude/
│   └── CLAUDE.md                            # 📖 プロジェクト指針（詳細な実装ガイド）
├── README.md                                # このファイル
├── README_original.md                       # 元の日本語 README（バックアップ）
├── LICENSE.txt
└── .gitignore
```

---

## 開発ドキュメント

### 🎯 Phase 0: 分析完了 ✅

**状況**: Windows EasyReforgeInstaller.bat の完全解析終了

詳細は **[docs/01_analysis_overview.md](docs/01_analysis_overview.md)** を参照してください。

#### Phase 0 の主な成果
- ✅ 160行の Windows インストーラーを 10-step フローに分解
- ✅ 全20+個の呼び出しスクリプトを特定
- ✅ 環境変数マッピング完了
- ✅ Ubuntu 移行ガイド作成済み
- ✅ 詳細な分析文書 5 ファイル作成

### 📋 実装計画（Phase 1-5）

**Phase 1 から Phase 5 までの詳細な実装計画は以下を参照してください**:

| ドキュメント | 説明 |
|-----------|------|
| [docs/02_planning_phases.md](docs/02_planning_phases.md) | 完全な実装フェーズ分解（週単位のタイムライン） |
| [docs/03_implementation_common_patterns.md](docs/03_implementation_common_patterns.md) | ステップバイステップの実装ガイド（注意事項付き） |
| [docs/03_implementation_phase1.md](docs/03_implementation_phase1.md) | Phase 1 の詳細実装手引き |
| [docs/04_reference_conversion_table.md](docs/04_reference_conversion_table.md) | Windows Batch → Ubuntu Shell 変換リファレンス |

---

## 現在のプロジェクトステータス

### 実装フェーズ進捗

```
Phase 0: Analysis & Design
[████████████████████████████████████████] ✅ COMPLETE
  分析文書作成: ✅ 完了
  設計ドキュメント: ✅ 完了

Phase 1: Foundation Scripts & Bootstrap (予定: 1-2週間)
[ ] 未開始
  easyreforge_installer.sh: [ ] 実装待機中
  github.sh helper: [ ] 実装待機中
  python.sh helper: [ ] 実装待機中

Phase 2: Core Environment Setup (予定: 3-4週間)
[ ] 未開始
  reforge.sh (CRITICAL): [ ] 実装待機中
  Extensions & Linking: [ ] 実装待機中

Phase 3-5: Download Helpers & Scripts
[ ] 未開始
  Download Infrastructure: [ ] 実装待機中
  Model Script Generation: [ ] 実装待機中
  Optional Launchers: [ ] 実装待機中
```

### 次のステップ

1. **Phase 0 分析ドキュメントを確認**
   → [docs/01_analysis_overview.md](docs/01_analysis_overview.md)

2. **実装計画の詳細を確認**
   → [docs/02_planning_phases.md](docs/02_planning_phases.md)

3. **Phase 1 実装を開始**
   → [docs/03_implementation_phase1.md](docs/03_implementation_phase1.md)

---

## 技術スタック

### 主なテクノロジー

- **Python**: 3.10+
- **PyTorch**: 2.7.1 with CUDA 12.8
- **reForge WebUI**: Git submodule (Panchovix 版)
- **ShellScript**: Bash 4.0+
- **OS**: Ubuntu 18.04+

### 依存パッケージ

- 198 個の Python パッケージ (`requirements.txt` 参照)
- 13 個の reForge 拡張機能
- CUDA Toolkit 12.8（GPU 使用の場合）

詳細は [.claude/CLAUDE.md](.claude/CLAUDE.md) の「Core Technologies & Dependencies」セクションを参照してください。

---

## ブランチ構成

```
main                           ← リリース版（現在は Windows 版）
  ↓
ubuntu-migration (現在地)      ← 📍 開発ブランチ（Phase 0完了、Phase 1準備中）
  ├── feature/phase-1         ← Phase 1 実装用
  ├── feature/phase-2         ← Phase 2 実装用
  └── ...
```

**デフォルトブランチ**: `ubuntu-migration`（開発用）

---

## 必要環境

### システム要件

- **OS**: Ubuntu 18.04 LTS 以上（20.04 / 22.04 推奨）
- **メモリ**: 16GB 以上
- **ディスク**: 20GB+ の空き容量
- **GPU**: NVIDIA RTX 3060+ 推奨（CUDA 12.8 対応）

### 必須ツール

```bash
# インストール確認
git --version           # 2.25+
bash --version          # 4.0+
python3 --version       # 3.10+
nvidia-smi              # NVIDIA GPU（推奨）

# 事前インストール
sudo apt-get update
sudo apt-get install -y git curl python3 python3-venv python3-pip \
    build-essential python3-dev xdg-utils shellcheck
```

---

## 開発者向け情報

### プロジェクト指針

実装に必要な全ての情報は **[.claude/CLAUDE.md](.claude/CLAUDE.md)** にあります：

- 📋 Phase ごとの詳細なチェックリスト
- ⚠️ 重要な実装の注意事項 7 つ
- 🔧 スクリプト構造テンプレート
- 📖 Batch → Shell 変換リファレンス

### 実装ガイド

1. **新規開発者はここから始める**:
   - [docs/01_analysis_overview.md](docs/01_analysis_overview.md) - Phase 0 分析の理解
   - [.claude/CLAUDE.md](.claude/CLAUDE.md) - クイックスタート

2. **実装時のリファレンス**:
   - [docs/03_implementation_common_patterns.md](docs/03_implementation_common_patterns.md) - ステップバイステップ
   - [docs/04_reference_conversion_table.md](docs/04_reference_conversion_table.md) - 個別変換

3. **問題が発生した場合**:
   - [docs/04_reference_troubleshooting.md](docs/04_reference_troubleshooting.md)
   - [docs/04_reference_known_issues.md](docs/04_reference_known_issues.md)

### コーディング規約

```bash
# すべての shell スクリプトで必須
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# 命名規則
lowercase_with_underscores.sh    # 正しい
CamelCase.sh                     # 避ける
kebab-case.sh                    # 避ける

# 検証
shellcheck script.sh             # 構文チェック
bash script.sh                   # 実行テスト
```

詳細は [.claude/CLAUDE.md](.claude/CLAUDE.md) を参照。

### 重要: 設計優先の開発プロセス

**バッチファイルの単純な構文置換は禁止です。**

各スクリプトを実装する前に、以下のプロセスに従ってください:

1. **バッチファイルの「目的」を理解する**
2. **Linux での最適な実装方法を設計する**
3. **shell-scripting Skill を活用する**
4. **構文リファレンスは補助的に使う**

詳細は [docs/03_implementation_common_patterns.md](docs/03_implementation_common_patterns.md) の「Batch File Analysis Process」セクションを参照。

---

## よくある質問

### Q: Windows 版との互換性は？

**A**: このリポジトリは Ubuntu 専用です。Windows 版は別リポジトリ（[Zuntan03/EasyReforge](https://github.com/Zuntan03/EasyReforge)）で管理されています。

### Q: 実装はいつ完了する？

**A**: Phase 0（分析）は完了しました。Phase 1 から Phase 5 まで合計 10-12 週間の予定です。詳細は [docs/02_planning_phases.md](docs/02_planning_phases.md) を参照してください。

### Q: 現在のコードは使える？

**A**: Phase 0 の分析文書は完成していますが、実装はまだ進行中です。完成したスクリプトは `docs/` フォルダに説明文書があります。

### Q: どうやって貢献できる？

**A**:
1. [.claude/CLAUDE.md](.claude/CLAUDE.md) でプロジェクト指針を確認
2. [docs/02_planning_phases.md](docs/02_planning_phases.md) で次のフェーズを確認
3. `ubuntu-migration` ブランチでフィーチャーブランチを作成
4. 実装→テスト→PR の流れで貢献

詳細は下記の「貢献方法」セクションを参照。

---

## 貢献方法

このプロジェクトへの貢献を歓迎します！

### 貢献の手順

1. **リポジトリをフォーク**
   ```bash
   git clone https://github.com/YOUR_USERNAME/EasyReforge-Ubuntu.git
   cd EasyReforge-Ubuntu
   ```

2. **`ubuntu-migration` ブランチで開発**
   ```bash
   git checkout ubuntu-migration
   git checkout -b feature/your-feature-name
   ```

3. **実装 → テスト → コミット**
   ```bash
   bash docs/03_implementation_phase1.md  # 実装ガイド参照
   shellcheck your_script.sh                        # 検証
   git add .
   git commit -m "Add feature: description"
   ```

4. **プルリクエストを作成**
   - `ubuntu-migration` ブランチを対象に PR を作成
   - 実装内容とテスト結果を記載

### 実装の優先順位

1. **Phase 1** - 基盤スクリプト（現在フォーカス）
2. **Phase 2** - コア環境セットアップ（最優先）
3. **Phase 3-5** - 追加機能

詳細は [docs/02_planning_phases.md](docs/02_planning_phases.md) を参照。

---

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE.txt](LICENSE.txt) を参照してください。

---

## 関連リンク

### 公式プロジェクト

- **元の Windows 版**: https://github.com/Zuntan03/EasyReforge
- **reForge WebUI**: https://github.com/Panchovix/stable-diffusion-webui-reForge
- **NoobAI Models**: https://civitai.com/models/833294
- **Stable Diffusion**: https://stability.ai/

### リソース

- **Civitai** (モデルダウンロード): https://civitai.com/
- **HuggingFace** (モデル・ライブラリ): https://huggingface.co/
- **CUDA Toolkit**: https://developer.nvidia.com/cuda-downloads
- **PyTorch**: https://pytorch.org/

### サポート

- **Issues**: https://github.com/Zuntan03/EasyReforge-Ubuntu/issues
- **Wiki**: https://github.com/Zuntan03/EasyReforge/wiki
- **元の Contact**: [@Zuntan03](https://x.com/Zuntan03)

---

## 謝辞

- [Panchovix](https://github.com/Panchovix) - reForge WebUI の開発・保守
- [Zuntan03](https://github.com/Zuntan03) - 元の Windows 版 EasyReforge
- Stable Diffusion コミュニティ全体

---

## プロジェクトメタデータ

| 項目 | 値 |
|------|-----|
| **プロジェクト名** | EasyReforge Ubuntu Migration |
| **バージョン** | 0.1.0 (Alpha - 開発中) |
| **ステータス** | 🚀 Phase 0 完了 → Phase 1 準備中 |
| **ブランチ** | `ubuntu-migration` (デフォルト) |
| **最終更新** | 2025-12-03 |
| **リポジトリサイズ** | 63MB |
| **スクリプト総数** | 237 個（.bat → .sh 変換対象） |
| **予想実装期間** | 10-12 週間（フル）、4-5 週間（コアのみ） |

---

## 変更ログ

### 2025-12-03
- **Phase 0 完了**: Windows インストーラー完全分析
- **ドキュメント作成**: 5 個の詳細分析文書
- **README 更新**: Ubuntu マイグレーション専用版に変更

詳細な変更履歴は `.claude/CLAUDE.md` の「File Modification Log」セクションを参照。

---

**ℹ️ 最初にこのリポジトリを見る方へ**

1. **このファイル** (README.md) を読む ← 今ここ
2. [docs/01_analysis_overview.md](docs/01_analysis_overview.md) - Phase 0 分析の理解
3. [.claude/CLAUDE.md](.claude/CLAUDE.md) - 詳細な実装指針と完全なチェックリスト
4. [docs/02_planning_phases.md](docs/02_planning_phases.md) - 実装計画の詳細

---

**🚀 開発開始準備中...**
Phase 1 実装は [.claude/CLAUDE.md](.claude/CLAUDE.md) の実装チェックリストを参照してください。
