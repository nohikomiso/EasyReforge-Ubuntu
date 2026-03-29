#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../../EasyReforge/Reforge/src/link_helper.sh"

main() {
    local link_src="${1:-}"
    local link_name

    if [ -z "$link_src" ]; then
        link_src=$(prompt_for_path "参照元のフォルダをドラッグ＆ドロップしてください")
    fi

    link_name=$(basename "$link_src")
    link_name=$(prompt_for_name "$link_name")

    create_symlink "${SCRIPT_DIR}/${link_name}" "$link_src"
}

main "$@"
