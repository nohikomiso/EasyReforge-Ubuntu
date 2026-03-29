---
trigger: always_on
description: EasyReforge-Ubuntu マイグレーションプロジェクトの基本ルールとアーキテクチャガイドライン
---

# EasyReforge Ubuntu 移行プロジェクト (Antigravity 用ルール)

このルールは、EasyReforgeのWindows向け環境（バッチスクリプト主体）をUbuntu（シェルスクリプト主体）へ移行するにあたり、コード生成およびタスク実行時にAntigravityが必ず遵守すべきガイドラインです。

## 1. プロジェクトの前提とアーキテクチャ
- **目的**: 237個のWindowsバッチファイル (.bat) をUbuntuシェルスクリプト (.sh) に移行する。
- **環境**: Ubuntu 24.04以上。
- **方針**: **❌ バッチファイルの単なる文法置換は絶対に行わないこと。**
  必ず元のバッチファイルが「何を達成しようとしているのか」を分析し、Ubuntu/Linux ネイティブなアプローチ (例: コピーには `rsync`、パッケージ導入には `apt` 等) を用いてゼロから再構築（設計）すること。

## 2. Shell スクリプト コーディング規約
生成・編集するすべてのシェルスクリプトは以下の規約に従うこと：

- **Shebang**: 必ず `#!/bin/bash` を使用する (`#!/bin/sh` は不可)。
- **安全性**: 先頭に必ず以下を記述し、エラー時に即座に停止させる。
  ```bash
  set -euo pipefail
  trap 'echo "Error on line $LINENO"; exit 1' ERR
  ```
- **スクリプトのパス取得**: 絶対パスの基準として以下を利用し、Windowsのパス区切り（`\`）やドライブレターは絶対に使用しない。
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ```
- **命名規則**: 関数名、変数名、ファイル名はすべてスネークケース (`lowercase_with_underscores`) を用いる（例: `easyreforge_installer.sh`）。
- **変数参照**: パスや文字列変数を展開する際は必ずダブルクォートで囲む (`"$VAR"`)。
- **モジュール化**: 他のスクリプトを読み込む際は、相対・絶対パスを明記して `source` を使用する (`source "${SCRIPT_DIR}/../lib/common.sh"`)。

## 3. ⚠️ 移行時における重要な注意事項とエッジケース
- **Python / PyTorch プラットフォームの差異**:
  Windows用 (win_amd64) のwheelファイルは利用できない。Linux用 (manylinux 等) の適切なwheelをダウンロードし、GPU (`nvidia-smi`で判定) またはCPU環境に応じたフォールバックを実装すること。
  SageAttention等、Linux用のwheelが存在しないプラグインはソースビルドのフォールバックを考慮する。
- **Virtual Environment の有効化**:
  Windowsの `venv\Scripts\activate.bat` への依存を排除し、`source "${VENV_PATH}/bin/activate"` を用いる。
- **シンボリックリンクの挙動**:
  Windowsのジャンクション（`MKLINK /J`）処理は、Linuxの `ln -s` に置き換えること。ディレクトリ構造の差異に注意する。
- **UTF-8 エンコーディング基準**:
  Windowsの `chcp 65001` の代わりに、スクリプト先頭付近で `export LC_ALL=C.UTF-8` を定義し、日本語UI等を破壊しないようにする。
- **インタラクティブ入力の回避**:
  非対話型シェル環境（CI/CDやパイプ処理）で `read -p` がハングアップするのを避けるため、`[ -t 0 ]` で TTY を判定し、必要に応じて環境変数やデフォルト値へフォールバックするロジックを組むこと。

## 4. Antigravity の行動指針
- **設計ファースト**: 実装前に必ず元のバッチスクリプトを読み（`view_file`等）、設計意図を把握してからLinuxシェルスクリプトのベストプラクティスを当てはめること。
- **環境設定の積極的確認**: 既存の `Phase 0` ドキュメントや `docs/` 以下のリファレンスが存在する場合は適宜読み込み、プロジェクトのフロー（10-step bootstrap 等）を破壊しないように配慮すること。
- **テスト自動化の意識**: 可能であればスクリプトに対して `shellcheck` をシミュレート（または実際に実行）し、安全に実行できる構成になっているか検証した上で完了とすること。