# プロジェクト概要 - EasyReforge Ubuntu移行

**プロジェクト名**: EasyReforge Windows → Ubuntu 完全移行
**最終更新**: 2025-12-03
**ステータス**: 計画完了・実装準備完了

---

## 目的

EasyReforge（Stable Diffusion WebUI reForge向けのターンキーインストーラー）を**Windows専用から Ubuntu専用へ完全移行**します。

### 背景

- EasyReforgeは現在Windows環境でのみ動作（237個の.batファイル）
- Linux/Ubuntu環境での需要が高まっている
- クロスプラットフォーム対応ではなく、**Ubuntu専用への完全移行**

---

## プロジェクトスコープ

### 変換対象

- **237個のWindowsバッチファイル（.bat）** → **Ubuntuシェルスクリプト（.sh）**
- すべての機能を維持したまま実装方法をLinux対応に

### 変換不要

以下はプラットフォームに依存しないため変換不要：

- Python スクリプト（.py）: ポータブル
- 設定ファイル（.csv, .json, .txt）: データファイル
- requirements.txt: Python パッケージリスト

---

## 主要な技術的課題

### 1. PyTorchプラットフォーム固有ホイール

- Windows: `torch-2.7.1+cu128-cp311-cp311-win_amd64.whl`
- Ubuntu: `torch-2.7.1+cu128-cp311-cp311-manylinux2014_x86_64.whl`

**対応**: GPU検出 → 正しいホイールダウンロード → フォールバック

### 2. シンボリックリンク vs ジャンクション

- Windows: `MKLINK /J` (NTFS ジャンクション)
- Ubuntu: `ln -s` (POSIX シンボリックリンク)

**対応**: セマンティクスの違いを理解し適切に実装

### 3. 仮想環境の有効化

- Windows: `venv\Scripts\activate.bat`
- Ubuntu: `source venv/bin/activate`

**対応**: パスを正しく設定し、検証ロジックを追加

### 4. UTF-8 エンコーディング

- Windows: `chcp 65001`
- Ubuntu: `export LC_ALL=C.UTF-8`

**対応**: すべてのスクリプトで環境変数を設定

---

## 実装フェーズ概要

### Phase 1: 基盤スクリプト（1-2週間）

**目標**: コア基盤が完成し、すべてのスクリプトがこの上に構築できる状態

- GitHub操作ヘルパー（github.sh）
- Python仮想環境ヘルパー（python.sh）
- インストーラー（easyreforge_installer.sh）
- アップデート（update.sh）
- セットアップ（setup.sh）

### Phase 2: コア環境セットアップ（3-4週間）

**目標**: reForge WebUIが完全に起動し、画像生成が可能な状態

- **CRITICAL**: reforge.sh（最重要・最複雑）
- 拡張機能インストール（reforge_extension.sh）
- シンボリックリンク作成（reforge_link.sh）
- 設定移行（reforge_config.sh, reforge_ui_config.sh）
- ランチャー（reforge_noptions.sh）

### Phase 3: ダウンロードヘルパー（5-6週間）

**目標**: 176個のモデルダウンロードスクリプト自動生成の基盤完成

- 7つのヘルパーライブラリ（common.sh, civitai_download.sh など）
- メタデータ抽出ツール
- 自動生成基盤の準備

### Phase 4: モデルスクリプト生成（7-8週間）

**目標**: 165以上のモデルダウンロードスクリプトを自動生成・検証

- 自動スクリプト生成（テンプレートベース）
- メタスクリプト変換
- 検証とテスト

### Phase 2b: モデルリンキング（9-10週間、並行実施）

**目標**: ユーザーが外部モデルディレクトリをシンボリックリンクで接続可能に

- link_input.sh テンプレート
- link_output.sh テンプレート
- 7カテゴリへの複製

### Phase 5: オプション機能・QA（11-12週間）

**目標**: Windows版との機能パリティ達成

- ランチャーバリアント変換
- LLM推論スクリプト変換
- エンドツーエンドテスト

---

## 成功基準

プロジェクトが成功とみなされる条件：

- [ ] 全237個のバッチファイルに対応する.shファイルが存在
- [ ] Ubuntu 18.04+で動作確認
- [ ] WebUI起動・画像生成動作
- [ ] モデルダウンロード機能動作
- [ ] シンボリックリンク機能動作
- [ ] 日本語UI完全対応（UTF-8）
- [ ] shellcheck 全スクリプト合格
- [ ] 複数Ubuntuバージョンでテスト済み
- [ ] ドキュメント完全
- [ ] ユーザーワークフローに変更なし

---

## 推定工数

### フル実装

- **期間**: 10-12週間
- **工数**: 155-200時間
- **範囲**: 全237スクリプト変換完了

### 高速実装（コアのみ）

- **期間**: 4-5週間
- **工数**: 50-70時間
- **範囲**: Phase 1-2のみ（基盤とコア環境）

---

## リスクと対策

### 高リスク

| リスク | 影響 | 対策 |
|--------|------|------|
| PyTorchホイール互換性 | 高 | GPU検出とフォールバック実装 |
| シンボリックリンク動作不良 | 中 | 徹底的なテストとPython走査確認 |
| SageAttention ビルド失敗 | 中 | ソースビルドのフォールバック |

### 中リスク

| リスク | 影響 | 対策 |
|--------|------|------|
| モデルダウンロードAPI変更 | 中 | バージョン固定とエラーハンドリング |
| 日本語UI表示問題 | 低 | UTF-8設定の徹底 |

---

## ステークホルダー

- **開発チーム**: スクリプト変換・テスト実施
- **プロジェクトマネージャー**: 進捗管理・リスク管理
- **QAチーム**: 統合テスト・検証
- **エンドユーザー**: Ubuntu環境でのEasyReforge利用者

---

## ドキュメント構成

このプロジェクトのドキュメントは以下のように整理されています：

```
docs/
├── 00_index_*.md              # ナビゲーションファイル（マスター、クイックスタート、アーキテクチャ）
│
├── 01_analysis_*.md           # フェーズ0：Windows インストーラー分析（4ファイル）
│   ├── overview.md            # 概要
│   ├── summary.md             # 要約
│   ├── technical.md           # 技術リファレンス
│   └── detailed.md            # フロー図と詳細分析
│
├── 02_planning_*.md           # 計画・設計（2ファイル）
│   ├── overview.md            # このファイル（日本語概要）
│   └── phases.md              # フェーズ1-5と全スクリプトインベントリ
│
├── 03_implementation_*.md      # 実装ガイド（6ファイル）
│   ├── common_patterns.md      # 共通パターンと注意事項（メイン）
│   ├── phase1.md              # フェーズ1 詳細
│   ├── phase2.md              # フェーズ2 詳細（CRITICAL）
│   ├── phase3.md              # フェーズ3 詳細
│   ├── phase4.md              # フェーズ4 詳細
│   └── phase5.md              # フェーズ5 詳細
│
├── 04_reference_*.md          # リファレンス（4ファイル）
│   ├── conversion_table.md     # コマンド変換テーブル
│   ├── checklist.md            # 実装チェックリスト
│   ├── known_issues.md         # 既知の問題と対策
│   └── troubleshooting.md      # トラブルシューティング
│
└── .claude/
    └── CLAUDE.md              # プロジェクト制御センター
```

---

## 次のステップ

1. **Phase 1開始**: easyreforge_installer.sh の実装
2. **ヘルパー作成**: github.sh, python.sh の実装
3. **統合テスト**: Phase 1完了後の動作確認
4. **Phase 2移行**: reforge.sh（最重要）の実装開始

---

**作成日**: 2025-12-03
**作成者**: EasyReforge Ubuntu移行チーム
**バージョン**: 1.0
