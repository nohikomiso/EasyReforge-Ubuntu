#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REFORGE_WEBUI="${REFORGE_ROOT}/stable-diffusion-webui-reForge"
EXTENSIONS_DIR="${REFORGE_WEBUI}/extensions"
BACKUP_DIR="${REFORGE_WEBUI}/extensions-backup"

source "${REFORGE_ROOT}/EasyReforge/src/lib/github.sh"

setup_directories() {
    echo "Setting up extensions directories..."
    mkdir -p "$EXTENSIONS_DIR"
    mkdir -p "$BACKUP_DIR"
}

move_to_backup() {
    local ext_name="$1"
    local src_dir="${EXTENSIONS_DIR}/${ext_name}"
    local dst_dir="${BACKUP_DIR}/${ext_name}"
    
    if [ -d "$src_dir" ]; then
        echo "Backing up ${ext_name}..."
        rm -rf "${dst_dir}"
        mv -f "$src_dir" "$dst_dir"
    fi
}

install_extensions() {
    echo "Installing extensions..."
    
    # Define an array of extensions: "owner repo hash"
    local extensions=(
        "DominikDoom a1111-sd-webui-tagcomplete c341ccccb6e10ec0b84403f4c95803532f6fd0aa"
        "Bing-su adetailer 36189cbea735b85fd01e98ac42002b8ce6f0e41d"
        "Panchovix reForge-Sigmas_merge 027b89f07d0d44fae12a1fab4a73f4f770a066cd"
        "adieyal sd-dynamic-prompts de056ff8d80e4ad120e13a90cf200f3383f427c6"
        "Haoming02 sd-forge-couple 707f72c1f8d4401e96eaeffbff5755fad9299b12"
        "blue-pen5805 sdweb-easy-generate-forever 2f507a03be3dd918765de114dd35c4f703805548"
        "altoiddealer --sd-webui-ar-plusplus 8b900cd2748f95bce455db62ba0cb08093a3ca59"
        "hako-mikan sd-webui-cd-tuner 99baedb599da874f9ee389aa44383bdda448a340"
        "hako-mikan sd-webui-lora-block-weight 34d2e0ce46a798f0b145d915470851623530bb85"
        "hako-mikan sd-webui-negpip 6ad0365f5a0ae8f66bc785f828a27720b8e6c3c2"
        "bluelovers sd-webui-pnginfo-beautify be63fa2d568cd135548a8eacb27a184776473c16"
        "nihedon sd-webui-weight-helper a4cc2f4d91ca75fc5e457d6d9fa113de622f803c"
        "zixaphir Stable-Diffusion-Webui-Civitai-Helper c2b9aa804ed5206ab5eaa111464643dbae6660c6"
        "Bocchi-Chan2023 stable-diffusion-webui-wd14-tagger 2d313188ae9176906e9d6c5138d4b1638ff19a09"
        "KohakuBlueleaf z-tipo-extension 32d61cf213f6346b05e69fc57fe830ecd9fbfca8"
        "L4Ph stable-diffusion-webui-localization-ja_JP d639f8ca6d635686806bebfc8fb6efbe9a71e636"
    )
    
    for ext in "${extensions[@]}"; do
        read -r owner repo commit <<< "$ext"
        echo "Installing $repo..."
        github_fetch_commit \
            "https://github.com/${owner}/${repo}.git" \
            "$commit" \
            "${EXTENSIONS_DIR}/${repo}"
    done
}

post_install_tasks() {
    echo "Running post-install tasks..."
    
    # 1. Backups (replacements)
    move_to_backup "sd-webui-ar"
    move_to_backup "sd-webui-lora-block-weight-reforge"
    
    # 2. ar-plusplus txt files
    local ar_path="${EXTENSIONS_DIR}/--sd-webui-ar-plusplus"
    if [ -d "$ar_path" ]; then
        local src_res="${SCRIPT_DIR}/src/resolutions.txt"
        local src_ar="${SCRIPT_DIR}/src/aspect_ratios.txt"
        
        if [ ! -f "${ar_path}/resolutions.txt" ] && [ -f "$src_res" ]; then
            cp "$src_res" "${ar_path}/"
        fi
        
        if [ ! -f "${ar_path}/aspect_ratios.txt" ] && [ -f "$src_ar" ]; then
            cp "$src_ar" "${ar_path}/"
        fi
    fi
    
    # 3. wd14-tagger utils.py patch
    local tagger_utils="${EXTENSIONS_DIR}/stable-diffusion-webui-wd14-tagger/tagger/utils.py"
    if [ -d "$(dirname "$tagger_utils")" ]; then
        curl -sS -kL -o "$tagger_utils" "https://gist.githubusercontent.com/Zuntan03/ec9010bef0f8fce5b752facd3f8053f0/raw"
    fi
}

main() {
    echo "============================================================="
    echo "Phase 2: reForge Extensions Setup"
    echo "============================================================="
    
    setup_directories
    
    # Run tasks
    post_install_tasks # backup first to avoid conflicts if they were previously installed
    install_extensions
    post_install_tasks # run again for post-clone file copies
    
    echo "reForge Extensions Setup complete."
}

main "$@"
