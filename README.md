# EasyReforge for Ubuntu

**Stable Diffusion WebUI reForge向けのターンキーインストーラー（Ubuntu専用）**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)
[![Ubuntu](https://img.shields.io/badge/ubuntu-20.04%20%7C%2022.04-orange.svg)](https://ubuntu.com/)
[![Python](https://img.shields.io/badge/python-3.10%2B-blue.svg)](https://python.org/)

---

## 概要

EasyReforgeは、[reForge WebUI](https://github.com/Panchovix/stable-diffusion-webui-reForge)（Stable Diffusion画像生成）のUbuntu環境向けインストーラーです。

> **注意**: これは元の[Windows版EasyReforge](https://github.com/Zuntan03/EasyReforge)をUbuntu専用に移行したバージョンです。

### 特徴

- ✅ **ワンコマンドインストール**: 複雑な環境構築を自動化
- ✅ **モデル管理**: Civitai/HuggingFaceから自動ダウンロード
- ✅ **日本語UI対応**: 完全な日本語ローカライゼーション
- ✅ **拡張機能**: ControlNet、Taggerなど13種類の拡張を自動セットアップ
- ✅ **CUDA最適化**: NVIDIA GPU対応（RTX 3060以上推奨）

---

## 必要環境

### 必須

- **OS**: Ubuntu 20.04 LTS / 22.04 LTS（推奨）
- **Python**: 3.10以上
- **Git**: 2.25以上
- **ディスク**: 20GB以上の空き容量
- **メモリ**: 16GB以上のRAM

### 推奨

- **GPU**: NVIDIA RTX 3060以上（VRAM 12GB以上）
- **CUDA**: 12.8以上
- **ネットワーク**: 高速インターネット接続（初回ダウンロード用）

### 事前準備

```bash
# 必要なツールをインストール
sudo apt-get update
sudo apt-get install -y git curl python3 python3-venv python3-pip \
    build-essential python3-dev xdg-utils

# NVIDIA GPUドライバー（GPU使用の場合）
sudo apt-get install -y nvidia-utils

# CUDA Toolkit 12.8（別途インストール必要）
# https://developer.nvidia.com/cuda-downloads
```

---

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/Zuntan03/EasyReforge-Ubuntu.git
cd EasyReforge-Ubuntu
```

### 2. インストール

```bash
bash EasyReforge/easyreforge_installer.sh
```

インストールには20-40分かかります（ネットワーク速度により変動）。

### 3. WebUI起動

```bash
bash reforge.sh
```

ブラウザで `http://localhost:7860` にアクセスしてください。

---

## ドキュメント

詳細なドキュメントは `docs/` ディレクトリにあります：

### クイックスタート
- **[docs/00_quickstart/README.md](docs/00_quickstart/README.md)** - プロジェクトガイド
- **[docs/00_quickstart/architecture.md](docs/00_quickstart/architecture.md)** - システムアーキテクチャ

### 計画・仕様
- [docs/01_planning/project_overview.md](docs/01_planning/project_overview.md) - プロジェクト概要
- [docs/01_planning/implementation_plan.md](docs/01_planning/implementation_plan.md) - 実装計画
- [docs/01_planning/phase_breakdown.md](docs/01_planning/phase_breakdown.md) - フェーズ詳細

### 実装ガイド
- [docs/02_implementation/phase_1/overview.md](docs/02_implementation/phase_1/overview.md) - Phase 1実装手引き
- [docs/02_implementation/common_patterns.md](docs/02_implementation/common_patterns.md) - 共通パターン

### リファレンス
- [docs/03_reference/batch_to_shell_conversion.md](docs/03_reference/batch_to_shell_conversion.md) - 変換テーブル
- **[docs/03_reference/troubleshooting.md](docs/03_reference/troubleshooting.md)** - トラブルシューティング
- [docs/03_reference/known_issues.md](docs/03_reference/known_issues.md) - 既知の問題
- [docs/03_reference/checklist.md](docs/03_reference/checklist.md) - 実装チェックリスト

---

## 主な機能

### モデルダウンロード

```bash
# NoobAI Epsilon v1.1をダウンロード
bash Download/Stable-diffusion/NoobE/NoobE_v11.sh

# すべてのStable Diffusionモデルをダウンロード
bash Download/All/AllStable-diffusion.sh
```

### モデルリンク

外部ディレクトリをWebUIにリンク：

```bash
# 外部モデルディレクトリをリンク
bash Model/Stable-diffusion/link_input.sh /path/to/external/models

# 出力先を外部ディレクトリにリンク
bash Model/Stable-diffusion/link_output.sh /path/to/output
```

### 拡張機能

自動インストールされる拡張機能（13種類）：

- ControlNet（画像制御）
- Tagger（タグ自動生成）
- Dynamic Prompts（プロンプト拡張）
- その他10種類

---

## トラブルシューティング

### よくある問題

#### WebUIが起動しない

```bash
# 仮想環境を確認
cd EasyReforge/Reforge
source venv/bin/activate
python --version  # Python 3.10以上か確認
```

#### PyTorchがCUDAを認識しない

```bash
# NVIDIA GPUを確認
nvidia-smi

# PyTorchを再インストール
pip install torch --index-url https://download.pytorch.org/whl/cu128
```

#### 日本語が文字化けする

```bash
# UTF-8ロケールを設定
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
echo 'export LC_ALL=C.UTF-8' >> ~/.bashrc
```

詳細は **[docs/03_reference/troubleshooting.md](docs/03_reference/troubleshooting.md)** を参照してください。

---

## 開発者向け情報

### プロジェクト構造

```
EasyReforge-Ubuntu/
├── docs/                       # ドキュメント
├── EasyReforge/                # メインインストール
│   ├── src/lib/               # ヘルパーライブラリ
│   └── Reforge/               # reForgeバリアント
├── Download/                   # モデルダウンロードスクリプト
├── Model/                      # モデルリンキングスクリプト
└── .claude/                    # プロジェクト指針
```

### 貢献方法

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

### コーディング規約

- シェルスクリプト: `shellcheck` で検証
- 命名規則: `lowercase_with_underscores`
- エラーハンドリング: `set -euo pipefail`
- ドキュメント: 変更時は必ずドキュメント更新

詳細は [.claude/CLAUDE.md](.claude/CLAUDE.md) を参照してください。

---

## プロジェクトステータス

**現在のステータス**: 📋 計画完了・実装準備中

### 実装フェーズ

- [ ] Phase 1: 基盤スクリプト（1-2週間）
- [ ] Phase 2: コア環境セットアップ（3-4週間）
- [ ] Phase 3: ダウンロードヘルパー（5-6週間）
- [ ] Phase 4: モデルスクリプト生成（7-8週間）
- [ ] Phase 2b: モデルリンキング（並行実施）
- [ ] Phase 5: オプション機能・QA（11-12週間）

詳細は [docs/01_planning/phase_breakdown.md](docs/01_planning/phase_breakdown.md) を参照してください。

---

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は [LICENSE.txt](LICENSE.txt) ファイルを参照してください。

---

## 関連リンク

### 公式プロジェクト
- **元のWindows版**: https://github.com/Zuntan03/EasyReforge
- **reForge WebUI**: https://github.com/Panchovix/stable-diffusion-webui-reForge
- **NoobAI Models**: https://civitai.com/models/833294

### リソース
- **Civitai**: https://civitai.com/
- **HuggingFace**: https://huggingface.co/
- **Troubleshooting Wiki**: https://github.com/Zuntan03/EasyReforge/wiki

---

## 謝辞

- [Panchovix/stable-diffusion-webui-reForge](https://github.com/Panchovix/stable-diffusion-webui-reForge) - reForge WebUI
- [Zuntan03/EasyReforge](https://github.com/Zuntan03/EasyReforge) - オリジナルWindows版
- Stable Diffusionコミュニティの皆様

---

## サポート

- **Issues**: https://github.com/Zuntan03/EasyReforge/issues
- **Wiki**: https://github.com/Zuntan03/EasyReforge/wiki
- **Contact**: [@Zuntan03](https://x.com/Zuntan03)

---

**最終更新**: 2025-12-03 | **バージョン**: 1.0 (Ubuntu) | **ステータス**: 開発中
