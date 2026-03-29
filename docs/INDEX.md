# EasyReforge Ubuntu Migration - Documentation Index

**このファイルは、人間およびAIエージェントが当プロジェクトの現在の状況・全体像を瞬時に把握するための「ルート（起点）ドキュメント」です。**
新しいセッションを開始したAIエージェントは、まずこのファイルを読み込んでプロジェクトの文脈とタスクを理解してください。

---

## 🗺️ 構成とナビゲーション（AI向けガイド）

ドキュメントフォルダは以下の5つのカテゴリに整理されています。目的に応じて必要なサブディレクトリ内のファイルを参照してください。

### 📌 1. 現在の作業状況・タスクを知りたい場合
最も優先して確認すべきファイルです。
* **[04_reference_checklist.md](04_reference/04_reference_checklist.md)**: 全フェーズのタスクと進捗状況（現在どのTaskを実装すべきか）が記載されています。

### 👷 2. これからコードを実装・設計する場合
スクリプトを書く際の具体的な要件、アーキテクチャ、`uv`パラダイムに基づくコーディング規約がまとまっています。
* **[00_index_architecture.md](00_index/00_index_architecture.md)**: 全体のディレクトリ構造とアーキテクチャ設計
* **[03_implementation_common_patterns.md](03_implementation/03_implementation_common_patterns.md)**: **【超重要】** バッチからシェルスクリプトへの変換ルールや実装パターン（uv runの使い方など）
* **03_implementation/03_implementation_phase*.md**: 各フェーズごとの具体的な実装の要件とコードサンプルが含まれたガイドです。現在の作業フェーズのファイルを確認してください。

### 📚 3. トラブルシューティングや制約事項を確認する場合
* **[04_reference_known_issues.md](04_reference/04_reference_known_issues.md)**: 特定のパッケージ・依存関係における既知のバグや問題とその回避策
* **[04_reference_troubleshooting.md](04_reference/04_reference_troubleshooting.md)**: 発生しうるエラーと解決手順

### 🔎 4. プロジェクトの背景・分析設計を知りたい場合
* **[00_index_master.md](00_index/00_index_master.md)**: プロジェクト全体の目次と簡単な説明
* **01_analysis/ フォルダ**: 移行元のWindowsバッチ処理群に対する解析レポート
* **02_planning/ フォルダ**: スケジュール計画とフェーズの概要定義

### 🛠️ 5. メンテナンス・リリース戦略を知りたい場合
* **[99_fork_and_porting_strategy.md](99_maintenance/99_fork_and_porting_strategy.md)**: **【重要】** 本家リスペクト、移植の作法、およびクローン配布時の戦略

---

## ⚡ 開発の最需要ルール (Antigravity 用ルール)
プロジェクトルートにある `/home/ytsubame/src/EasyReforge-Ubuntu/.agents/rules/rule1.md` あるいはグローバルルールに記載されていますが、ここで再確認します。

1. **`uv` 環境の絶対採用**: `python3 -m venv` による仮想環境や、`source /activate` 等で行う手動の有効化は完全に廃止されました。すべてのPythonの実行やパッケージインストールには `uv run` および `uv pip install` を用います。
2. **Bashスクリプトの安全性**: 自動生成する `.sh` スクリプトの先頭には必ず `set -euo pipefail` を記述し、`SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` で絶対パスの基準を設けてください。
3. **対話プロンプトでのハングアップ回避**: 非対話型シェルにおける `read -p` でのUIハングを防ぐため、エージェントにはバックグラウンドでの `(CMD) && exit 0 || exit 1` の書式を推奨します。
4. **【超重要】環境変数カスケードアーキテクチャ**: 最初にダウンロードされる単一のインストーラースクリプト（起点の `.sh`）で定義した設定変数は、後からクローン・実行されるすべての子スクリプト（`setup.sh` など）へ伝播させるため、必ず `export` で公開し、受け手側は `${VAR:-default}` のフォールバック評価で安全に受け取ってください。未使用警告等により自己判断で変数を削除しないでください。

---

*この INDEX.md ファイルは、セッションを跨いで文脈を保ち、迷子にならないための中継地点として機能します。*
