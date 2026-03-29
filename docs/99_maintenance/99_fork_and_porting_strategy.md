# Fork and Porting Strategy: EasyReforge-Ubuntu

## 1. プロジェクトの定義とビジョン
**EasyReforge-Ubuntu** は、オリジナルの Windows 版 EasyReforge (および Zuntan 氏による EasyEnv/EasyTools) の設計思想を継承しつつ、Ubuntu (POSIX) 環境へ最適化するために再構築された **「プラットフォーム移植版 (Platform Port)」** です。

本プロジェクトの目的は、Windows 固有の制約から解放された、堅牢で高速な Ubuntu ネイティブの Stable Diffusion 環境を提供することにあります。

## 2. 倫理的指針：本家へのリスペクトとクレジット
本プロジェクトは、オリジナルの開発者たちの多大なる貢献の上に成り立っています。
- **出典の明記**: README および本ドキュメントにおいて、オリジナルの Windows 版 (Zuntan03 氏、nohikomiso 氏等) へのリンクと謝辞を常に維持します。
- **Hard Fork の正当性**: OS 間の根本的な仕様差（パス区切り、仮想環境管理、シェルスクリプト等）により、ソースコードの 90% 以上が変更されていますが、その「設計思想（使いやすさ、自動化）」は本家から受け継いだものです。

## 3. 論理的指針：本家 (Upstream) との同期戦略
本プロジェクトは本家から大きく乖離しているため、単純な `git merge` は推奨されません。
- **論理的な同期 (Cherry-picking)**: 本家で更新された `metadata.csv` (モデルデータ) や、WebUI 自体の新しい設定パラメータのみを抽出し、Ubuntu 版へ手動または部分的に取り込みます。
- **非互換性の維持**: Windows 固有の `.bat` ファイルや絶対パス記述を本家から取り込むことは避け、常に Ubuntu 版の POSIX 準拠コードを優先します。

## 4. リリース戦略：クリーンな歴史の構築
開発中の試行錯誤（コンフリクト修正や一時的なデバッグ）をユーザーに見せないため、以下の運用を推奨します。
- **Development Branch (`ubuntu-migration`)**: 詳細な開発履歴をすべて保持。
- **Main Branch (`main`)**: 開発ブランチの成果を `merge --squash` により一点のコミットに集約して公開。

これにより、一般ユーザーには「洗練された初期リリース」を提供しつつ、開発者は過去の修正経緯を `ubuntu-migration` ブランチで遡ることが可能になります。

---
*Created by: Antigravity Assistant & USER*
*Date: 2026-03-30*
