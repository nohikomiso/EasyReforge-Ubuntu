# 既知の問題 - EasyReforge Ubuntu

**最終更新**: 2025-12-03

このドキュメントでは、EasyReforge Ubuntu移行における既知の問題、制限事項、および回避策をまとめています。

---

## カテゴリ別インデックス

1. [プラットフォーム固有の問題](#プラットフォーム固有の問題)
2. [依存関係の問題](#依存関係の問題)
3. [機能制限](#機能制限)
4. [パフォーマンスの問題](#パフォーマンスの問題)
5. [互換性の問題](#互換性の問題)
6. [計画中の改善](#計画中の改善)

---

## プラットフォーム固有の問題

### 問題1: PyTorch Wheelプラットフォーム差異

**ステータス**: 🟡 回避策あり

**説明**:
- Windows版: `torch-2.7.1+cu128-cp310-cp310-win_amd64.whl`
- Linux版: `torch-2.7.1+cu128-cp310-cp310-manylinux_2_17_x86_64.whl`

プラットフォーム固有のwheel名が異なるため、ダウンロードURLを動的に構築する必要があります。

**回避策**:
```bash
# reforge.sh で実装済み
detect_platform() {
    if [ "$(uname -s)" = "Linux" ]; then
        WHEEL_PLATFORM="manylinux2014_x86_64"
    fi
}
```

**影響**:
- インストールスクリプトが複雑化
- テストが各プラットフォームで必要

**解決予定**: Phase 2実装時に対応済み

---

### 問題2: SageAttention Linux Wheel 不足

**ステータス**: 🔴 未解決（調査中）

**説明**:
SageAttention 2.2.0のLinux用pre-built wheelが公式に提供されていない可能性があります。

**影響**:
- ソースからのビルドが必要
- インストール時間が増加（5-10分追加）
- ビルド依存関係が必要（gcc, CUDA toolkit）

**回避策**:

**オプション1**: ソースビルド
```bash
# ビルド環境準備
sudo apt-get install -y build-essential cuda-toolkit-12-8

# ソースからインストール
pip install sageattention==2.2.0 --no-binary sageattention
```

**オプション2**: スキップ（オプショナル機能）
```bash
# requirements.txt からコメントアウト
# この場合、一部の最適化が無効になるが動作には影響なし
```

**調査事項**:
- [ ] 公式リポジトリでLinux wheelの提供状況確認
- [ ] コミュニティビルドwheel探索
- [ ] 代替最適化ライブラリ検討

---

### プラットフォーム固有Wheel利用可能性と対応方法

#### PyTorch (torch, torchvision, torchaudio)
- **ステータス**: ✅ WindowsおよびLinux両方で利用可能
- **アクション**: PyTorchインデックスを通じた自動インストール（`--index-url https://download.pytorch.org/whl/cu128`）
- **プラットフォームタグ**:
  - Windows: `cp310-cp310-win_amd64`
  - Linux: `cp310-cp310-manylinux_2_17_x86_64`

#### SageAttention 2.2.0
- **ステータス**: ✅ Linuxwheel利用可能（ユーザー構築）
- **保存場所**: `EasyReforge/Reforge/wheels/sageattention-2.2.0-cp310-cp310-linux_x86_64.whl`
- **アクション**: ローカルwheelファイルからインストール
- **フォールバック**: 利用不可の場合はスキップ（重要でないパフォーマンス最適化）

#### llama-cpp-python 0.3.4
- **ステータス**: ⚠️ LinuxのCUDA対応pre-builtwheel不足
- **アクション**: CUDA対応でソースからビルド
- **コマンド**: `CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python==0.3.4`
- **時間**: ~10-15分のビルド時間
- **フォールバック**: ビルド失敗時はCPU版（`pip install llama-cpp-python==0.3.4`）

#### triton-windows
- **ステータス**: ❌ Windows専用、Linux不要
- **アクション**: Ubuntu版のrequirements.txtから削除
- **理由**: PyTorchはLinuxにネイティブTritonを含みます

#### pywin32, pyreadline3
- **ステータス**: ❌ Windows専用、Linux不要
- **アクション**: Ubuntu版のrequirements.txtから削除
- **理由**: Windows COM/レジストリアクセスおよびターミナルサポート（Linuxはネイティブ相当機能あり）

---

### 問題3: シンボリックリンクのセマンティクス差異

**ステータス**: 🟡 回避策あり

**説明**:
- **Windows**: `MKLINK /J` はディレクトリジャンクション（カーネルレベル透過）
- **Linux**: `ln -s` はシンボリックリンク（ファイルシステムレベル）

Pythonがシンボリックリンクを走査する際、動作が異なる可能性があります。

**具体例**:
```python
# Windows (ジャンクション)
os.path.isdir("models/Stable-diffusion")  # True (透過的)

# Linux (シンボリックリンク)
os.path.islink("models/Stable-diffusion")  # True
os.path.isdir("models/Stable-diffusion")   # True（追従）
os.path.realpath("models/Stable-diffusion")  # リンク先を返す
```

**影響**:
- WebUIがモデルを認識しない可能性（低確率）
- `os.walk()` の動作が異なる可能性

**回避策**:
```bash
# リンク先の権限を確実に設定
chmod -R a+rX Model/Stable-diffusion/

# Python側でシンボリックリンク追従を明示
# (reForge WebUIは既に対応済み)
```

**テスト済み**: reForge WebUI 2024.12.03時点で動作確認済み

---

## 依存関係の問題

### 問題4: llama-cpp-python コンパイル要求

**ステータス**: 🟡 回避策あり

**説明**:
`llama-cpp-python` はC++拡張を含むため、Linux環境ではコンパイルが必要な場合があります。

**影響**:
- インストール時間増加（5-15分）
- ビルド依存関係が必要

**回避策**:

**オプション1**: Pre-built wheelを使用
```bash
pip install llama-cpp-python --prefer-binary
```

**オプション2**: CUDA有効でビルド
```bash
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python
```

**オプション3**: CPU版のみ
```bash
pip install llama-cpp-python
# GPU加速なしだが動作は可能
```

**必要な依存関係**:
```bash
sudo apt-get install -y \
    build-essential \
    cmake \
    libopenblas-dev \
    python3-dev
```

---

### 問題5: CUDA Toolkit バージョン依存

**ステータス**: 🟡 回避策あり

**説明**:
PyTorch 2.7.1+cu128 はCUDA 12.8を要求しますが、Ubuntu 18.04/20.04のデフォルトリポジトリには含まれていません。

**注記**: PyTorchバンドルCUDAを使用するため、別途CUDA Toolkitをインストール不要です。

**影響**:
- 手動でCUDA Toolkitをインストール必要
- バージョン不一致による動作不良

**回避策**:

**CUDA 12.8インストール**:
```bash
# NVIDIA公式リポジトリ追加
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update

# CUDA Toolkit 12.8インストール
sudo apt-get install -y cuda-toolkit-12-8

# 環境変数設定
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH
```

**CPU版フォールバック**:
```bash
# GPU不要な場合
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

---

### 問題6: cuDNN バージョン要求

**ステータス**: 🟡 回避策あり

**説明**:
CUDA 12.8と互換性のあるcuDNNが必要です（cuDNN 8.9以上推奨）。

**回避策**:
```bash
# cuDNNインストール（NVIDIAアカウント必要）
# 1. https://developer.nvidia.com/cudnn からダウンロード
# 2. tarボールを展開
tar -xvf cudnn-linux-x86_64-8.9.x.x_cuda12-archive.tar.xz

# 3. ライブラリをコピー
sudo cp cudnn-*-archive/include/cudnn*.h /usr/local/cuda/include
sudo cp -P cudnn-*-archive/lib/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
```

---

## 機能制限

### 問題7: インタラクティブ入力の非TTY対応

**ステータス**: 🟡 部分対応

**説明**:
`read -p` コマンドは非TTY環境（cron, systemd, パイプ）で動作しません。

**影響**:
- `Model/*/link_input.sh` が自動化スクリプトから呼び出せない
- `Model/*/link_output.sh` も同様

**回避策**:

**現在の実装**:
```bash
# TTY検出
if [ -t 0 ]; then
    read -p "Enter path: " user_input
else
    # 非TTY時はデフォルト使用
    user_input="${DEFAULT_PATH:-/opt/models}"
fi
```

**パイプ入力対応**:
```bash
# パイプから入力
echo "/external/models" | bash Model/Stable-diffusion/link_input.sh

# 環境変数から入力
MODEL_PATH="/external/models" bash Model/Stable-diffusion/link_input.sh
```

**計画中の改善**:
- [ ] 環境変数による完全自動化対応
- [ ] 設定ファイルからの読み込み対応

---

### 問題8: Windows特有機能の非対応

**ステータス**: ✅ 設計による制限（意図的）

**説明**:
以下のWindows専用機能はUbuntu版では対応しません：

- PowerShell スクリプト実行
- レジストリ操作（LongPathsEnabled）
- VC Runtime 自動インストール
- Portable Git ダウンロード

**影響**:
- Windows版からの直接移行は不可
- Ubuntu環境での再インストール必要

**代替手段**:
- Git: `apt-get install git`
- Python: `apt-get install python3`
- 設定: 環境変数で管理

---

## パフォーマンスの問題

### 問題9: 初回インストールの時間

**ステータス**: 🟡 改善計画中

**説明**:
初回インストール時、以下の処理に時間がかかります：

- PyTorchダウンロード（~2GB）: 5-10分
- requirements.txt（198パッケージ）: 10-20分
- reForge submoduleクローン（~1GB）: 5-10分

**合計**: 20-40分（ネットワーク速度依存）

**改善計画**:
- [ ] 並列ダウンロード実装（aria2c）
- [ ] ローカルキャッシュ活用
- [ ] 差分アップデート最適化

---

### 問題10: モデルダウンロード速度

**ステータス**: 🟡 部分改善

**説明**:
CivitaiおよびHuggingFaceからのダウンロードが遅い場合があります。

**原因**:
- API レート制限
- ネットワーク帯域制限
- シーケンシャルダウンロード

**改善策**:
```bash
# aria2c による並列ダウンロード
sudo apt-get install -y aria2
export USE_ARIA2=1
```

**計画中**:
- [ ] 並列ダウンロード対応（Phase 3）
- [ ] ミラーサーバー対応検討
- [ ] レジューム機能実装

---

## 互換性の問題

### 問題11: Ubuntu 18.04 サポート限界

**ステータス**: 🟡 限定サポート

**説明**:
Ubuntu 18.04（2023年4月EOL）では一部パッケージが古い可能性があります。

**推奨環境**:
- Ubuntu 20.04 LTS（推奨）
- Ubuntu 22.04 LTS（最新）
- Ubuntu 24.04 LTS（将来）

**18.04での問題**:
- Python 3.10が標準リポジトリにない
- CUDA Toolkit 12.8が非対応

**回避策**:
```bash
# deadsnakes PPAでPython 3.10
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.10 python3.10-venv
```

---

### 問題12: 他のLinuxディストリビューション非対応

**ステータス**: 🔴 未対応

**説明**:
現在Ubuntu専用設計のため、他のディストリビューションでは動作保証なし。

**非対応ディストリビューション**:
- Debian
- Fedora / RedHat
- Arch Linux
- openSUSE

**将来的な対応可能性**:
- [ ] Debian対応（類似性高い）
- [ ] Fedora対応（パッケージマネージャー差異大）

---

## 計画中の改善

### Phase 1-2 実装完了後

- [ ] エラーハンドリング強化
- [ ] ログ出力改善
- [ ] 進捗表示実装

### Phase 3-4 実装完了後

- [ ] ダウンロード並列化
- [ ] レート制限対応
- [ ] キャッシュ機構

### Phase 5 実装完了後

- [ ] 複数Ubuntuバージョンテスト
- [ ] パフォーマンス最適化
- [ ] ドキュメント充実化

---

## 報告方法

新しい問題を発見した場合：

1. **GitHub Issues**: https://github.com/Zuntan03/EasyReforge/issues
2. **情報収集**:
   ```bash
   # システム情報
   uname -a
   lsb_release -a
   python3 --version
   nvidia-smi

   # ログ収集
   bash -x script.sh 2>&1 | tee error.log
   ```

3. **報告内容**:
   - 発生手順
   - エラーメッセージ
   - 環境情報
   - 期待される動作

---

## バージョン履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0 | 2025-12-03 | 初版作成 |

---

**作成日**: 2025-12-03
**ステータス**: 継続更新中
