#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# 関数1: 仮想環境を作成
# 使用例: uv_create_venv "/path/to/venv"
uv_create_venv() {
    local venv_path="$1"

    if [ -d "$venv_path" ]; then
        echo "Venv already exists at $venv_path"
        return 0
    fi

    echo "Creating virtual environment at $venv_path..."
    # uv init --bare でプロジェクトを初期化し、直後に venv を作成
    local venv_dir
    venv_dir=$(dirname "$venv_path")
    (cd "$venv_dir" && uv init --bare) 2>/dev/null || true
    
    uv venv "$venv_path" --python 3.10

    # 権限設定
    chmod -R u+w "$venv_path"

    return 0
}

# 関数2: 仮想環境を有効化
# 使用例: uv_activate_venv "/path/to/venv"
# 注意: この関数は source で実行される必要がある
uv_activate_venv() {
    local venv_path="$1"

    if [ ! -f "$venv_path/bin/activate" ]; then
        echo "Error: activate script not found at $venv_path/bin/activate"
        return 1
    fi

    # ポイント: source で実行することで、現在のシェルに環境を反映
    # shellcheck disable=SC1090,SC1091  # 動的ファイルパスのため、およびソース追跡不可のため
    source "$venv_path/bin/activate"

    return 0
}

# 関数3: パッケージをインストール
# 使用例: uv_install_packages "/path/to/venv" "requirements.txt"
uv_install_packages() {
    local venv_path="$1"
    local requirements_file="$2"

    if [ ! -f "$requirements_file" ]; then
        echo "Error: requirements file not found: $requirements_file"
        return 1
    fi

    echo "Installing packages from $requirements_file..."
    # uv pip を使用 (仮想環境パスを VIRTUAL_ENV で指定)
    VIRTUAL_ENV="$venv_path" uv pip install -r "$requirements_file"

    return 0
}

# 関数4: venv の有効化を検証
# 使用例: uv_verify_activation
uv_verify_activation() {
    # venv が有効かどうか検証
    # set -u環境下で未定義エラーを防ぐため ${VIRTUAL_ENV:-} を使用
    if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
        echo "Error: Virtual environment not activated"
        return 1
    fi

    echo "Virtual environment active: $VIRTUAL_ENV"
    return 0
}

# メイン実行
main() {
    : # このファイルはライブラリ
}
