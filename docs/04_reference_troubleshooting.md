# トラブルシューティングガイド - EasyReforge Ubuntu

**最終更新**: 2025-12-03

---

## 一般的な問題と解決策

### カテゴリ別インデックス

1. [インストール問題](#インストール問題)
2. [Python環境問題](#python環境問題)
3. [PyTorchインストール問題](#pytorchインストール問題)
4. [シンボリックリンク問題](#シンボリックリンク問題)
5. [モデルダウンロード問題](#モデルダウンロード問題)
6. [WebUI起動問題](#webui起動問題)
7. [日本語UI表示問題](#日本語ui表示問題)
8. [拡張機能問題](#拡張機能問題)

---

## インストール問題

### 問題1: `git: command not found`

**症状**:
```bash
bash easyreforge_installer.sh
git: command not found
```

**原因**: Gitがインストールされていない

**解決策**:
```bash
sudo apt-get update
sudo apt-get install -y git
```

**確認**:
```bash
git --version
# git version 2.25.1 以上であること
```

---

### 問題2: `python3: command not found`

**症状**:
```bash
bash easyreforge_installer.sh
python3: command not found
```

**原因**: Python 3がインストールされていない

**解決策**:
```bash
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip
```

**確認**:
```bash
python3 --version
# Python 3.10 以上であること
```

**注意**: Python 3.8以下の場合、アップグレードが必要：
```bash
sudo apt-get install -y python3.10 python3.10-venv python3.10-dev
```

---

### 問題3: `Permission denied` エラー

**症状**:
```bash
bash easyreforge_installer.sh
Permission denied: /home/user/EasyReforge-Ubuntu
```

**原因**: 書き込み権限がない

**解決策**:
```bash
# 1. ディレクトリの所有権を確認
ls -ld /home/user/EasyReforge-Ubuntu

# 2. 所有権を変更（必要な場合）
sudo chown -R $USER:$USER /home/user/EasyReforge-Ubuntu

# 3. 権限を設定
chmod -R u+rwx /home/user/EasyReforge-Ubuntu
```

---

## Python環境問題

### 問題4: 仮想環境が有効化されない

**症状**:
```bash
source venv/bin/activate
# プロンプトが変わらない
```

**原因**: `source` が正しく実行されていない

**解決策**:
```bash
# 1. フルパスで指定
source /home/user/EasyReforge-Ubuntu/EasyReforge/Reforge/venv/bin/activate

# 2. プロンプトが変わることを確認
# (venv) user@host:~$

# 3. Python パスを確認
which python
# /home/user/EasyReforge-Ubuntu/EasyReforge/Reforge/venv/bin/python
```

**デバッグ**:
```bash
# venv が正しく作成されているか確認
test -d venv && echo "venv exists" || echo "venv missing"

# activate スクリプトが存在するか確認
test -f venv/bin/activate && echo "activate exists" || echo "activate missing"
```

---

### 問題5: `pip install` が失敗する

**症状**:
```bash
pip install -r requirements.txt
ERROR: Could not find a version that satisfies the requirement...
```

**原因**: pip バージョンが古い、またはパッケージが見つからない

**解決策**:
```bash
# 1. pip をアップグレード
python -m pip install --upgrade pip

# 2. requirements.txt を再インストール
pip install -r requirements.txt --no-cache-dir

# 3. 個別パッケージを確認
pip install torch --index-url https://download.pytorch.org/whl/cu128
```

**代替案**:
```bash
# ビルド依存関係をインストール
sudo apt-get install -y build-essential python3-dev

# 再試行
pip install -r requirements.txt
```

---

### 問題6: `ModuleNotFoundError: No module named 'venv'`

**症状**:
```bash
python3 -m venv venv
/usr/bin/python3: No module named venv
```

**原因**: `python3-venv` パッケージが未インストール

**解決策**:
```bash
sudo apt-get install -y python3-venv
```

---

## PyTorchインストール問題

### 問題7: PyTorchがCUDAを認識しない

**症状**:
```python
import torch
torch.cuda.is_available()
# False
```

**原因**: CUDA版PyTorchがインストールされていない、またはCUDAドライバーが未インストール

**解決策**:

**ステップ1**: NVIDIA GPUとドライバーを確認
```bash
nvidia-smi
# GPU情報が表示されるか確認
```

**ステップ2**: CUDA Toolkitバージョンを確認
```bash
nvcc --version
# CUDA Version 12.8 以上
```

**ステップ3**: PyTorchを再インストール
```bash
pip uninstall torch torchvision torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
```

**ステップ4**: 確認
```python
import torch
print(torch.cuda.is_available())  # True
print(torch.cuda.get_device_name(0))  # GPU名
```

---

### 問題8: SageAttention ビルド失敗

**症状**:
```bash
pip install sageattention-2.2.0-cp311-cp311-linux_x86_64.whl
ERROR: Could not find a version that satisfies...
```

**原因**: Linux版wheelが存在しない、またはビルド環境が不足

**解決策**:

**オプション1**: ソースからビルド
```bash
# ビルド依存関係
sudo apt-get install -y build-essential python3-dev cuda-toolkit-12-8

# ソースからインストール
pip install sageattention --no-binary sageattention
```

**オプション2**: スキップ（オプショナル機能）
```bash
# requirements.txt から該当行をコメントアウト
sed -i 's/^sageattention/#sageattention/' requirements.txt
```

---

### 問題9: llama-cpp-python コンパイルエラー

**症状**:
```bash
pip install llama-cpp-python
error: command 'gcc' failed with exit status 1
```

**原因**: C++コンパイラーまたはCUDA開発ツールが未インストール

**解決策**:
```bash
# 必要なツールをインストール
sudo apt-get install -y \
    build-essential \
    cmake \
    libopenblas-dev \
    python3-dev \
    cuda-toolkit-12-8

# CUDA有効でビルド
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python
```

---

## シンボリックリンク問題

### 問題10: シンボリックリンクが作成されない

**症状**:
```bash
bash reforge_link.sh
ln: failed to create symbolic link: Permission denied
```

**原因**: 書き込み権限がない、または既存ファイルが存在

**解決策**:
```bash
# 1. 宛先ディレクトリの権限確認
ls -ld stable-diffusion-webui-reForge/models/Stable-diffusion/

# 2. 既存リンク・ファイルを削除
rm -rf stable-diffusion-webui-reForge/models/Stable-diffusion

# 3. 再実行
bash reforge_link.sh
```

---

### 問題11: シンボリックリンクが壊れている

**症状**:
```bash
ls -l stable-diffusion-webui-reForge/models/Stable-diffusion/
lrwxrwxrwx ... Stable-diffusion -> /nonexistent/path (broken)
```

**原因**: リンク先が存在しない、または移動された

**解決策**:
```bash
# 1. 壊れたリンクを削除
find stable-diffusion-webui-reForge/models/ -xtype l -delete

# 2. 正しいパスを確認
ls -ld Model/Stable-diffusion/

# 3. リンクを再作成
ln -s "$(pwd)/Model/Stable-diffusion" \
    stable-diffusion-webui-reForge/models/Stable-diffusion
```

---

### 問題12: WebUIがシンボリックリンク経由でモデルを認識しない

**症状**: WebUIのモデル一覧にモデルが表示されない

**原因**: Python がシンボリックリンクを正しく走査していない可能性

**解決策**:
```bash
# 1. シンボリックリンクが正しいか確認
readlink stable-diffusion-webui-reForge/models/Stable-diffusion

# 2. ターゲットディレクトリが読み取り可能か確認
ls -la "$(readlink stable-diffusion-webui-reForge/models/Stable-diffusion)"

# 3. 権限を設定
chmod -R a+rX Model/Stable-diffusion/

# 4. WebUIを再起動
```

---

## モデルダウンロード問題

### 問題13: Civitai ダウンロードが403エラー

**症状**:
```bash
bash Download/Stable-diffusion/NoobE/AniKawa.sh
HTTP 403 Forbidden
```

**原因**: Civitai APIキーが未設定、またはレート制限

**解決策**:
```bash
# 1. Civitai APIキーを取得
# https://civitai.com/user/account → API Keys

# 2. 環境変数に設定
export CIVITAI_API_KEY="your_api_key_here"

# 3. 再試行
bash Download/Stable-diffusion/NoobE/AniKawa.sh
```

**永続化**:
```bash
# ~/.bashrc に追加
echo 'export CIVITAI_API_KEY="your_api_key_here"' >> ~/.bashrc
source ~/.bashrc
```

---

### 問題14: HuggingFace ダウンロードが遅い

**症状**: ダウンロード速度が非常に遅い（数KB/s）

**原因**: ネットワーク制限、またはミラーサーバー問題

**解決策**:
```bash
# 1. aria2c を使用した並列ダウンロード
sudo apt-get install -y aria2

# 2. ダウンロードスクリプトで aria2c を優先
# (Download/lib/huggingface_download.sh で実装)

# 3. タイムアウト設定を調整
export DOWNLOAD_TIMEOUT=300  # 5分
```

---

### 問題15: ダウンロードが途中で止まる

**症状**: ダウンロードが進行せず、タイムアウトもしない

**原因**: ネットワーク不安定、またはサーバー側問題

**解決策**:
```bash
# 1. ダウンロードをキャンセル (Ctrl+C)

# 2. 部分ダウンロードファイルを削除
rm -f Model/Stable-diffusion/*.tmp

# 3. リトライロジックを有効化
export DOWNLOAD_RETRY=5  # 5回リトライ

# 4. 再実行
bash Download/Stable-diffusion/NoobE/AniKawa.sh
```

---

## WebUI起動問題

### 問題16: WebUIが起動しない

**症状**:
```bash
bash Reforge_NoOptions.sh
Error: Could not find module 'torch'
```

**原因**: 仮想環境が有効化されていない、またはPyTorchが未インストール

**解決策**:
```bash
# 1. 仮想環境を手動で有効化
cd EasyReforge/Reforge
source venv/bin/activate

# 2. PyTorchがインストールされているか確認
python -c "import torch; print(torch.__version__)"

# 3. インストールされていない場合
pip install torch --index-url https://download.pytorch.org/whl/cu128

# 4. WebUIを起動
python stable-diffusion-webui-reForge/webui.py
```

---

### 問題17: `Address already in use` エラー

**症状**:
```bash
OSError: [Errno 98] Address already in use
```

**原因**: ポート7860が既に使用中

**解決策**:
```bash
# 1. 使用中のプロセスを確認
lsof -i :7860

# 2. プロセスを終了
kill <PID>

# 3. または別のポートを使用
python stable-diffusion-webui-reForge/webui.py --port 7861
```

---

### 問題18: `CUDA out of memory` エラー

**症状**:
```bash
RuntimeError: CUDA out of memory. Tried to allocate 2.00 GiB
```

**原因**: GPU VRAMが不足

**解決策**:
```bash
# 1. バッチサイズを減らす（WebUI設定）
# Settings → Batch size: 1

# 2. 低VRAMモードを有効化
# Settings → Low VRAM: ON

# 3. コマンドライン引数でメモリ最適化
python webui.py --medvram  # 8GB VRAM
python webui.py --lowvram  # 4GB VRAM
```

---

## 日本語UI表示問題

### 問題19: 日本語が文字化けする

**症状**: WebUIで日本語が `???` や `□□□` で表示される

**原因**: UTF-8ロケールが設定されていない

**解決策**:
```bash
# 1. ロケールを確認
locale
# LC_ALL が C.UTF-8 または ja_JP.UTF-8 であること

# 2. 環境変数を設定
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# 3. ~/.bashrc に追加（永続化）
echo 'export LC_ALL=C.UTF-8' >> ~/.bashrc
echo 'export LANG=C.UTF-8' >> ~/.bashrc

# 4. WebUIを再起動
```

---

### 問題20: プロンプトで日本語が使えない

**症状**: プロンプト入力欄に日本語を入力できない

**原因**: ブラウザまたはIME設定の問題

**解決策**:
```bash
# 1. ブラウザの言語設定を確認
# Chrome/Firefox → 設定 → 言語 → 日本語追加

# 2. Ubuntu のIME設定を確認
sudo apt-get install -y ibus-mozc

# 3. ibus を起動
ibus-daemon -drx
```

---

## 拡張機能問題

### 問題21: 拡張機能が表示されない

**症状**: WebUIの拡張機能タブに何も表示されない

**原因**: 拡張機能が正しくクローンされていない

**解決策**:
```bash
# 1. 拡張機能ディレクトリを確認
ls -la stable-diffusion-webui-reForge/extensions/

# 2. reforge_extension.sh を再実行
bash EasyReforge/Reforge/reforge_extension.sh

# 3. WebUIを再起動
```

---

### 問題22: 特定の拡張機能がエラーを起こす

**症状**:
```bash
Error loading extension 'sd-webui-controlnet': ...
```

**原因**: 拡張機能のバージョン不整合、または依存関係不足

**解決策**:
```bash
# 1. 該当拡張機能を無効化
mv stable-diffusion-webui-reForge/extensions/sd-webui-controlnet \
    stable-diffusion-webui-reForge/extensions/sd-webui-controlnet.disabled

# 2. WebUIを起動して動作確認

# 3. 拡張機能を特定コミットに戻す
cd stable-diffusion-webui-reForge/extensions/sd-webui-controlnet
git checkout <commit-hash>

# 4. 有効化して再起動
```

---

## デバッグテクニック

### 一般的なデバッグ手順

```bash
# 1. 詳細ログを有効化
bash -x script.sh 2>&1 | tee debug.log

# 2. ShellCheck で構文チェック
shellcheck script.sh

# 3. 環境変数を確認
env | grep -E "CUDA|PYTHON|PATH"

# 4. プロセスを確認
ps aux | grep python
ps aux | grep webui

# 5. ディスク容量を確認
df -h

# 6. メモリ使用量を確認
free -h

# 7. GPU状態を確認
nvidia-smi
watch -n 1 nvidia-smi  # リアルタイム監視
```

---

## ログファイル

### 主要ログファイルの場所

```bash
# インストールログ
cat EasyReforge/install.log

# WebUIログ
cat stable-diffusion-webui-reForge/webui.log

# 拡張機能ログ
cat stable-diffusion-webui-reForge/extensions/*/logs/*.log

# システムログ
journalctl -xe
```

---

## よくある質問 (FAQ)

### Q1: インストールにどれくらい時間がかかりますか？

**A**: 環境により異なりますが：
- 初回インストール: 30-60分
- モデルダウンロード込み: 1-2時間
- ネットワーク速度に大きく依存

### Q2: どれくらいのディスク容量が必要ですか？

**A**:
- コア環境: 10GB
- モデル（最小）: 10GB
- モデル（推奨）: 50GB以上
- 合計推奨: 70GB以上

### Q3: GPU なしでも動作しますか？

**A**: はい、CPU版PyTorchで動作しますが：
- 画像生成速度が10-50倍遅くなります
- メモリ使用量が増加します
- 推奨: NVIDIA RTX 3060以上

### Q4: Windows版から設定を移行できますか？

**A**: はい、以下のファイルをコピー：
- `config.json`
- `ui-config.json`
- `styles.csv`（カスタム分のみ）

---

## サポートリソース

- **公式Wiki**: https://github.com/Zuntan03/EasyReforge/wiki
- **reForge Issues**: https://github.com/Panchovix/stable-diffusion-webui-reForge/issues
- **Ubuntu フォーラム**: https://ubuntuforums.org/

---

**作成日**: 2025-12-03
**バージョン**: 1.0
