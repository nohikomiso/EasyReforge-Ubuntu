#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../EasyReforge/Reforge/src/link_helper.sh"

main() {
    local link_dst="${1:-}"
    local link_name

    if [ -z "$link_dst" ]; then
        link_dst=$(prompt_for_path "参照先の親フォルダをドラッグ＆ドロップしてください")
    fi

    # デフォルトのリンク名は自身のディレクトリ（このスクリプトがあるディレクトリの親から見た名前）
    link_name=$(basename "$SCRIPT_DIR")
    link_name=$(prompt_for_name "$link_name")

    # 指定された親ディレクトリの中に自身を参照するリンクを作る
    create_symlink "${link_dst}/${link_name}" "$SCRIPT_DIR"
}

main "$@"
