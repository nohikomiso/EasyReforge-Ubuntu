# スクリプト変換リファレンス - Windows Batch から Ubuntu Shell へ

**Windowsバッチコマンドを同等のUbuntuシェルコマンドに変換するためのクイックルックアップテーブル**

---

## ⚠️ 重要: このテーブルは「構文リファレンス」です

**このテーブルの使い方**:
- ✅ 特定のコマンド構文をすぐに調べる必要があるときに使う
- ✅ 「Windowsで `%VAR%` を使っていた場合、Ubuntuではどう書く?」という質問に答える
- ❌ 実装計画の主要な参考資料として使う
- ❌ 「バッチを単純に変換すればいい」という判断で使う

**実装の流れ** (重要):
1. バッチファイルの「目的」を理解する（このテーブルではなく、`.bat`ファイルを読む）
2. Linux での最適な実装方法を設計する
3. 必要な「構文」をこのテーブルから探す（3番目のステップ）

**参考**: `.claude/CLAUDE.md` の「Script Conversion Guidelines」を必ず読んでください

---

## 変数の扱い

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `set VAR=value` | `VAR=value` | スクリプトローカル |
| `set VAR=value&& echo %VAR%` | `VAR=value; echo "$VAR"` | セミコロンで順次実行 |
| `set /p VAR=prompt:` | `read -p "prompt: " VAR` | 対話的入力 |
| `echo %VAR%` | `echo "$VAR"` | 単語分割を防ぐためクォートを使用 |
| `echo !VAR!` (遅延展開) | `echo "${VAR}"` (同じコンテキスト) | bashでは遅延展開不要 |
| `%~dp0` | `"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` | スクリプトディレクトリ |
| `%~nx1` | `"${1##*/}"` | パラメータのベース名 |
| `%ERRORLEVEL%` | `$?` | 最後のコマンドの終了コード |
| `%USERNAME%` | `$USER` または `$(whoami)` | 現在のユーザー |
| `%USERPROFILE%` | `$HOME` | ユーザーホームディレクトリ |
| `%TEMP%` | `$TMPDIR` または `$HOME/.cache` | 一時ディレクトリ |

---

## パスとファイル操作

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `cd /d C:\path` | `cd /path` | スラッシュを使用 |
| `pushd dir & popd` | `(cd dir; ...)` | 分離ディレクトリ用のサブシェル |
| `if exist path\` | `if [ -d "path/" ]` | ディレクトリが存在 |
| `if exist file.txt` | `if [ -f "file.txt" ]` | ファイルが存在 |
| `mkdir dir` | `mkdir -p dir` | 親ディレクトリも作成 |
| `del /f file.txt` | `rm -f file.txt` | 強制削除 |
| `rmdir /s /q dir` | `rm -rf dir` | 再帰的削除（注意！） |
| `copy /y src dst` | `cp src dst` | ファイルコピー |
| `xcopy /sqy src\ dst\` | `cp -r src/* dst/` または `rsync -av src/ dst/` | ディレクトリコピー |
| `ren oldname newname` | `mv oldname newname` | 名前変更/移動 |
| `move /y src dst` | `mv src dst` | ファイル/ディレクトリ移動 |
| `findstr "pattern" file` | `grep "pattern" file` | ファイル内のテキスト検索 |
| `findstr /r "regex" file` | `grep -E "regex" file` | 正規表現検索 |
| `for /d %%d in (dir\*)` | `for dir in dir/*/; do ... done` | ディレクトリをループ |
| `for /r %%f in (*.ext)` | `find . -name "*.ext" -type f` | ファイルを再帰的に検索 |
| `dir /s` | `ls -R` または `find .` | 再帰的にリスト |
| `cd /d %~dp0` | `cd "$(dirname "${BASH_SOURCE[0]}")"` | スクリプトディレクトリに移動 |

---

## 文字列操作

| Windows Batch | Ubuntu Bash | 備考 |
|--------------|-------------|----------|
| `%VAR:old=new%` | `${VAR//old/new}` | すべての出現を置換 |
| `%VAR:~0,5%` | `${VAR:0:5}` | 部分文字列（最初の5文字） |
| `%VAR:~-3%` | `${VAR: -3}` | 最後の3文字 |
| `call :label` | `function_name` | 関数呼び出し |
| `setlocal enabledelayedexpansion` | bashでは不要 | 遅延展開は自動処理 |
| `%random%` | `$RANDOM` | 0-32767のランダム数 |
| `if "%VAR%"=="" ` | `if [ -z "$VAR" ]` | 空文字列チェック |
| `if not "%VAR%"=="" ` | `if [ -n "$VAR" ]` | 非空チェック |
| `if /i "%VAR%"=="value"` | `if [ "${VAR,,}" = "value" ]` | 大文字小文字を区別しない（bash 4+） |

---

## 条件ロジック

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `if condition (...)` | `if condition; then ... fi` | 基本的なif-then |
| `if not condition (...)` | `if ! condition; then ... fi` | !で否定 |
| `if condition (...) else (...)` | `if condition; then ... else ... fi` | If-else |
| `if %ERRORLEVEL% neq 0` | `if [ $? -ne 0 ]` | 終了コードチェック |
| `if exist path (...)` | `if [ -d "path" ]; then ... fi` | パスが存在 |
| `if /i %VAR%==value` | `if [ "$VAR" = "value" ]` | 文字列の等価性 |
| `if "%VAR%"=="" (...)` | `if [ -z "$VAR" ]; then ... fi` | 空文字列 |
| `if defined VAR` | `if [ -n "${VAR:-}" ]` | 変数が定義されている |
| `if %VAR% geq 5` | `if [ "$VAR" -ge 5 ]` | 数値比較 |
| `goto label` | `function_name` または `return` | ラベルにジャンプ |

---

## 数値演算

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `set /a num=5+3` | `num=$((5+3))` | 算術展開 |
| `if %num% gtr 10` | `if [ "$num" -gt 10 ]` | より大きい |
| `if %num% lss 10` | `if [ "$num" -lt 10 ]` | より小さい |
| `if %num% equ 10` | `if [ "$num" -eq 10 ]` | 等しい |

---

## ループ

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `for %%i in (1 2 3)` | `for i in 1 2 3; do ... done` | リストをループ |
| `for /l %%i in (1,1,5)` | `for i in {1..5}; do ... done` | 数値範囲 |
| `for /d %%d in (*)` | `for dir in */; do ... done` | ディレクトリをループ |
| `for /r %%f in (*.txt)` | `while IFS= read -r f; do ... done < <(find . -name "*.txt")` | 再帰的ファイルループ |
| `for /f "tokens=1" %%a in (file)` | `while IFS= read -r a rest; do ... done < file` | 行のパース |

---

## 関数とサブルーチン

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `:label` ... `call :label` | `function_name() { ... } function_name` | 関数定義 |
| `exit /b 0` | `return 0` | 関数から戻る |
| `exit /b 1` | `return 1` | エラーで戻る |
| `setlocal` | 関数内で `local var=value` | ローカルスコープ |
| `%~1` | `"$1"` | 最初の引数 |
| `%~dp0` | `"$(dirname "${BASH_SOURCE[0]}")"` | スクリプトディレクトリ |
| `%*` | `"$@"` | すべての引数（クォート付き） |
| `%#` | `$#` | 引数の数 |

---

## 出力とログ

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `echo message` | `echo "message"` | 行を出力 |
| `echo. ` | `echo ""` | 空行 |
| `echo off` | (同等なし) | Bashはデフォルトで静か |
| `cls` | `clear` | 画面クリア |
| `echo message > file` | `echo "message" > file` | ファイルにリダイレクト（上書き） |
| `echo message >> file` | `echo "message" >> file` | ファイルに追記 |
| `echo %VAR% 2>&1 \| tee log.txt` | `echo "$VAR" \| tee log.txt` | 出力とログ |
| `color 0a` | (同等なし) | シェルスクリプトに色なし |
| `@echo off` | (同等なし) | デバッグ時は"set +x"を使用 |

---

## Git操作

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `git clone URL` | `git clone URL` | リポジトリをクローン |
| `git fetch origin` | `git fetch origin` | 更新を取得 |
| `git reset --hard` | `git reset --hard` | HEADにリセット |
| `git reset --hard COMMIT` | `git reset --hard COMMIT` | 特定のコミットにリセット |
| `git checkout branch` | `git checkout branch` | ブランチを切り替え |
| `git config user.name` | `git config user.name` | すべてのプラットフォームで同じ |

---

## ネットワーク操作

| Windows Batch | Ubuntu Shell | 備考 |
|--------------|-------------|----------|
| `C:\Windows\System32\curl.exe` | `curl` | システムcurlを使用 |
| `curl -L URL` | `curl -L URL` | リダイレクトに従う |
| `curl -o output URL` | `curl -o output URL` | ファイルに保存 |
| `curl -fL URL` | `curl -fL URL` | HTTPエラーで失敗 |
| `powershell -Command "(New-Object Net.WebClient).DownloadFile('URL','file')"` | `curl -L -o file URL` | ファイルをダウンロード |

---

## 環境変数

| Windows | Ubuntu | 目的 |
|---------|--------|---------|
| `%APPDATA%\.triton\cache` | `$HOME/.triton/cache` | Tritonコンパイルキャッシュ |
| `%TEMP%\torchinductor_%USERNAME%` | `$HOME/.cache/torch/inductor_$(whoami)` | PyTorchキャッシュ |
| `chcp 65001` | `export LC_ALL=C.UTF-8` | UTF-8エンコーディング |
| `%CUDA_PATH%` | `$CUDA_HOME` または自動検出 | CUDAツールキットの場所 |
| `%PYTHONPATH%` | `export PYTHONPATH=...` | Pythonモジュールパス |

---

## エラーハンドリングパターン

| Windows Batch | Ubuntu Shell | 使用例 |
|--------------|-------------|----------|
| `if %ERRORLEVEL% neq 0 (...)` | `if [ $? -ne 0 ]; then ... fi` | 最後のコマンドをチェック |
| `command \|\| exit /b 1` | `command \|\| exit 1` | エラーで終了 |
| `setlocal enabledelayedexpansion` | `set -euo pipefail` | 厳格モード |
| `call :error_label` | trapで構造化 | エラーハンドリング |
| N/A | `trap 'cleanup' EXIT` | 終了時のクリーンアップ |
| N/A | `set -e` | 最初のエラーで終了 |

---

## 一般的なBatchパターン → Shell相当

### パターン1: 安全なディレクトリナビゲーション

**Batch**:
```batch
pushd %~dp0..\..Model
REM ... 操作 ...
popd
```

**Shell**（同等）:
```bash
(
    cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/Model"
    # ... 操作 ...
)
```

---

### パターン2: 条件付きスクリプト実行

**Batch**:
```batch
if exist setup.bat (
    call setup.bat
) else (
    echo Setup script not found
    exit /b 1
)
```

**Shell**:
```bash
if [ -f setup.sh ]; then
    bash setup.sh
else
    echo "Setup script not found" >&2
    exit 1
fi
```

---

### パターン3: 安全な変数展開

**Batch**:
```batch
setlocal enabledelayedexpansion
for %%f in (*.txt) do (
    echo !DATE! - %%f >> log.txt
)
```

**Shell**:
```bash
for f in *.txt; do
    echo "$(date) - $f" >> log.txt
done
```

---

### パターン4: エラー伝播

**Batch**:
```batch
call some_script.bat
if %ERRORLEVEL% neq 0 (
    echo Error in some_script
    exit /b %ERRORLEVEL%
)
```

**Shell**（`set -e`を使用）:
```bash
#!/bin/bash
set -e
trap 'echo "Error in some_script"; exit 1' ERR

some_script.sh

# some_scriptが成功した場合のみ残りのスクリプトが実行される
```

---

### パターン5: 対話的入力

**Batch**:
```batch
set /p CHOICE="Enter your choice: "
if "%CHOICE%"=="1" (
    REM ...
)
```

**Shell**:
```bash
read -p "Enter your choice: " CHOICE

case "$CHOICE" in
    1)
        # ...
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
```

---

### パターン6: ファイル存在チェックと作成

**Batch**:
```batch
if not exist dir (
    mkdir dir
)
cd dir
```

**Shell**:
```bash
mkdir -p dir
cd dir
```

---

### パターン7: 再帰的ディレクトリ操作

**Batch**:
```batch
for /r %%f in (*.txt) do (
    echo Processing %%f
    REM ...
)
```

**Shell**:
```bash
find . -name "*.txt" -type f | while read f; do
    echo "Processing $f"
    # ...
done
```

---

### パターン8: 設定ファイルの更新

**Batch**:
```batch
setlocal enabledelayedexpansion
for /f "tokens=1,* delims==" %%a in (config.txt) do (
    if "%%a"=="KEY" (
        echo KEY=newvalue >> output.txt
    ) else (
        echo %%a=%%b >> output.txt
    )
)
```

**Shell**（sedを使用）:
```bash
sed 's/^KEY=.*/KEY=newvalue/' config.txt > output.txt
```

---

## よくある落とし穴と回避方法

### 落とし穴1: クォートされていない変数

**間違い**:
```bash
echo $VAR          # VARにスペースが含まれていると壊れる
cd $SCRIPT_DIR     # パスにスペースがあると失敗
```

**正しい**:
```bash
echo "$VAR"        # 安全
cd "$SCRIPT_DIR"   # 常にクォート
```

---

### 落とし穴2: パイプラインで終了コードが失われる

**間違い**:
```bash
set -e
some_command | grep pattern  # grepが何も見つけないとスクリプトが停止！
```

**正しい**:
```bash
set -e
some_command | grep pattern || true  # または適切に処理
```

---

### 落とし穴3: サブシェルの誤用

**間違い**:
```bash
(cd some_dir; VAR=value)
echo $VAR  # VARは空（サブシェルスコープ）
```

**正しい**:
```bash
cd some_dir
VAR=value
cd -
echo $VAR  # VARに値がある
```

---

### 落とし穴4: 関数内の相対パス

**間違い**:
```bash
my_function() {
    cd relative/path  # 異なるディレクトリから呼び出されると失敗
}
```

**正しい**:
```bash
my_function() {
    local original_dir="$(pwd)"
    cd "$(dirname "${BASH_SOURCE[0]}")/relative/path"
    # ... 作業 ...
    cd "$original_dir"
}
```

---

### 落とし穴5: シンボリックリンクを含むスクリプトディレクトリ

**間違い**:
```bash
SCRIPT_DIR="$(dirname "$0")"  # シンボリックリンクの場所を指す可能性
```

**正しい**:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # シンボリックリンクを解決
```

---

### 落とし穴6: ロケールの問題

**間違い**:
```bash
# ロケール設定なし
# プロンプト内の日本語文字が正しく表示されない可能性
```

**正しい**:
```bash
#!/bin/bash
export LC_ALL=C.UTF-8

# これで日本語文字が機能する
echo "モデルをダウンロードしています..."
```

---

### 落とし穴7: エラーハンドリングの欠如

**間違い**:
```bash
curl URL -o file
unzip file  # curlが失敗した場合に失敗する可能性
```

**正しい**:
```bash
#!/bin/bash
set -euo pipefail

curl URL -o file || { echo "Download failed"; exit 1; }
unzip file || { echo "Unzip failed"; exit 1; }
```

---

## Batch変換のクイックチェックリスト

各スクリプトを変換する前に確認:

- [ ] 変数を設定しているか？ `set`を`VAR=`に置き換え
- [ ] `%ERRORLEVEL%`を使用しているか？ `$?`または`set -e`に置き換え
- [ ] `pushd/popd`を使用しているか？ サブシェル`(cd ...)`に置き換え
- [ ] `chcp`を使用しているか？ `export LC_ALL=C.UTF-8`に置き換え
- [ ] VC Runtimeを使用しているか？ 完全に削除
- [ ] レジストリを変更しているか？ 完全に削除
- [ ] `%~dp0`を使用しているか？ スクリプトディレクトリ展開に置き換え
- [ ] `\`パスを使用しているか？ `/`に置き換え
- [ ] `call script.bat`を使用しているか？ `bash script.sh`に置き換え
- [ ] 対話的入力を期待しているか？ `set /p`の代わりに`read -p`を使用

---

## 参考資料

- **Bashマニュアル**: https://www.gnu.org/software/bash/manual/
- **ShellCheck**: https://www.shellcheck.net/ （構文検証ツール）
- **POSIXシェル**: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html

---

このリファレンスは、EasyReforgeに必要なbatch-to-shell変換の95%をカバーしているはずです。
複雑なケースについては、より詳細なパターンについてIMPLEMENTATION_GUIDE.mdを参照してください。
