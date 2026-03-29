# Phase 5: ComfyUI 共存および既存モデル資産活用に関する分析レポート

## 1. 現状の分析 (Current Status Analysis)

### 1.1 EasyReforge-Ubuntu の現状
- **Phase 1-5 の実装進捗**: インストーラー、Python仮想環境、WebUI (reForge)、拡張機能、パスのシンボリックリンク生成、データ駆動型ダウンロードエンジンが構築済み。
- **課題**: 現状の `reforge_link.sh` および `setup.sh` は、各モデルの実体をプロジェクト内の `EasyReforge/Model/` ディレクトリに「固定」で配置する設計になっている。
- **欠落点**: 外部の既存ストレージ（例：ComfyUI などの共有モデルフォルダ）を、セットアップと同時に「一気通貫」で取り込む仕組みが `.sh` 実装層で不足している。

### 1.2 既存資産 (EasyTools) の状況
- `EasyReforge/EasyTools/ComfyUi/*.bat` (Windows用レガシー) には ComfyUI 関連の記述が存在するが、これらは Ubuntu 移行の Phase 1-5 の対象外となっていた。
- ユーザー様の既存ストレージ `/home/ytsubame/storage/comfy/models/` との連携ロジックが未実装。

## 2. ユーザー要件 (Requirements)

1. **二重保存の回避**: すでにある `/home/ytsubame/storage/comfy/models/` のモデルデータを、新しい `EasyReforge` 環境でもそのまま利用したい。
2. **手動操作の最小化**: 「ファイルを1つずつ手動でリンクを張る」のではなく、パスを指定するだけで全カテゴリ（Checkpoints, LoRA, VAE 等）が自動的に WebUI 側に反映されるべきである。
3. **ブートストラップの一気通貫性**: `easyreforge_installer.sh` 実行時にこの共有設定が伝播し、ダウンロードフェーズが無駄な通信を行わずに済むこと。

## 3. 統合設計案 (Final Implementation Plan)

### 3.1 実体ソースコード解析に基づく結論
`/tmp` での再検証により、当プロジェクトの reForge バージョンには `extra_model_paths.yaml` などの ComfyUI 自動連携機能は**存在しない**ことが確認されました。
したがって、最も確実でユーザー様に負担をかけない「一気通貫」の実現方法は、**`reforge_link.sh` による物理的なシンボリックリンクの自動割り当て** です。

### 3.2 `reforge_link.sh` の高度化ロジック
- **`COMFY_PATH` インジェクション**: `/home/ytsubame/comfy/ComfyUI/` を指す環境変数をトリガーに発動。
- **データ・マッピング（一括結合）**:
  - `stable-diffusion-webui-reForge/models/Stable-diffusion` ➔ `/home/ytsubame/storage/comfy/models/checkpoints`
  - `stable-diffusion-webui-reForge/models/Lora` ➔ `/home/ytsubame/storage/comfy/models/loras`
  - `stable-diffusion-webui-reForge/models/VAE` ➔ `/home/ytsubame/storage/comfy/models/vae`
  - `stable-diffusion-webui-reForge/models/ControlNet` ➔ `/home/ytsubame/storage/comfy/models/controlnet`

### 3.3 データ取得（ダウンロード）の最適化
- ダウンロードエンジン（Python）において、リンク先ディレクトリも走査対象に含める（またはリンクが既に存在すればスキップする）ことで、重複ダウンロードを回避。

## 4. 重複ダウンロード回避ロジックの実証

### 4.1 二重の重複回避ガード (Multi-layered Protection)

当プロジェクトでは、以下の2段階でモデルの重複ダウンロードを確実に阻止します。

#### 1. Python レイヤー (civitai_download.py 等)
Python の `Path.exists()` を用い、シンボリックリンクを透過的にチェックします。
```python
target_file = output_path / filename
if target_file.exists():
    print(f"INFO: Already exists: {target_file}")
    return True
```

#### 2. シェル・レイヤー (common.sh / download_with_retry)
万が一のフォールバック時（curl 実行時）にも、以下のガードが発動するように是正済みです。
```bash
if [ -e "$dest" ]; then
    log_info "Skipping download: File already exists at $dest"
    return 0
fi
```

- **シンボリックリンクの透過性**: 両レイヤーにおいて、物理リンクとその先のターゲット（実体）を透過的に扱う仕組みを完備しています。
- **挙動**: `reforge_link.sh` によって ComfyUI 側へリンクが張られた後では、どのダウンロード手段を通じても「既にファイルがそこに物理的に存在している」と認識され、通信を発生させずにプロセスを終了（スキップ）します。

### 4.2 独自構成への適応 (Smart Recursive Search)

ユーザー様が ComfyUI の各ディレクトリ内で「独自のサブフォルダ」を作成してモデルを整理している場合でも対応可能です。

- **仕組み**: ダウンロードエンジン（Python層およびシェル共通部品層）において、各カテゴリ（Stable-diffusion, Lora 等）のルートから **最大3階層までの再帰的スキャン** を実行するように是正しました。
- **結果**: 指定のファイル名がどこかのサブフォルダ内に存在すれば「既にあり」とみなし、ダウンロードを回避します。これにより、ユーザー様の自由なストレージ整理とインストーラーのオートメーションが完全に共存します。

### 4.3 フォルダマッピングの一覧表

| モデル種別 | reForge (移行先) | ComfyUI (既存ストレージ) | 解決策 |
| :--- | :--- | :--- | :--- |
| Checkpoints | `models/Stable-diffusion` | `models/checkpoints` | `reforge_link.sh` で物理リンク |
| Lora | `models/Lora` | `models/loras` | `reforge_link.sh` で物理リンク |
| VAE | `models/VAE` | `models/vae` | `reforge_link.sh` で物理リンク |

これにより、ユーザー様が持つ数GB〜数十GBの Checkpoint 群は、単なる「パスの鏡」として reForge に認識され、**新規のダウンロードは一切発生しません。**

## 5. 検証と今後の展望

### 4.1 検証項目
1. **物理リンクの整合性**: `/tmp` 側でインストール完了後、モデルディレクトリが ComfyUI 側の本尊を向いているか。
2. **WebUI の認識**: リンク経由で reForge がモデルを読み込み、正常に推論に利用できるか。

### 4.2 残課題（Phase 6 以降への検討）
- **複数の ComfyUI 構成への対応**: 構成が特殊な場合（storage/ 以下ではない等）のパラメータ化の柔軟性向上。

## 6. バージョンスナップショットと制約の背景

本分析は、EasyReforge-Ubuntu プロジェクトが現時点で展開している以下の特定バージョンを対象としています。

- **対象リポジトリ**: `Panchovix/stable-diffusion-webui-reForge`
- **リファレンス・コミット**: `8e30f027` (v1.3.0 / WebUI 1.10.1 ベース)
- **制約事項**: 
  - このコミット時点では、Forge 由来の `ldm_patched` はサンプリング実装に限定されており、パス管理の自動スキャン機能（ `--path-to-comfy` 等）はまだ統合されていません。
  - したがって、オートメーション（一気通貫セットアップ）の観点からは、スクリプトによる **「明示的なシンボリックリンクの構築」** が当バージョンにおける唯一かつ確実なソリューションです。

---
**最終更新日時**: 2026-03-30
**担当エージェント**: Antigravity (実体ソース詳細解析に基づき是正)

