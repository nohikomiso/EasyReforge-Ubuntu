#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REFORGE_WEBUI="${REFORGE_ROOT}/stable-diffusion-webui-reForge"
EASY_MODEL_DIR="${REFORGE_ROOT}/EasyReforge/Model"

# Function: Create symlink safely (Linux equivalent of mklink /j)
# Usage: make_symlink <TARGET_DIR_ABSOLUTE_PATH> <LINK_DIR_ABSOLUTE_PATH>
make_symlink() {
    local target_dir="$1"
    local link_dir="$2"
    
    # Ensure target directory exists (as actual directory)
    mkdir -p "$target_dir"
    
    if [ -L "$link_dir" ]; then
        local current_target
        current_target=$(readlink -f "$link_dir" || readlink "$link_dir")
        local expected_target
        expected_target=$(readlink -f "$target_dir" || echo "$target_dir")
        
        if [ "$current_target" != "$expected_target" ]; then
            echo "Updating symlink: $link_dir -> $target_dir"
            rm -f "$link_dir"
            ln -s "$target_dir" "$link_dir"
        else
            echo "Symlink already exists and valid: $link_dir -> $target_dir"
        fi
    elif [ -d "$link_dir" ]; then
        ls_res=$(ls -A "$link_dir" 2>/dev/null || true)
        if [ -z "$ls_res" ]; then
            # Directory is empty
            rm -rf "$link_dir"
            echo "Creating symlink: $link_dir -> $target_dir"
            ln -s "$target_dir" "$link_dir"
        else
            echo "Moving contents to target and replacing with symlink: $link_dir -> $target_dir"
            cp -rn "$link_dir"/* "$target_dir"/ 2>/dev/null || true
            rm -rf "$link_dir"
            ln -s "$target_dir" "$link_dir"
        fi
    elif [ -e "$link_dir" ]; then
        echo "WARNING: $link_dir exists but is not a directory. Cannot create link."
    else
        echo "Creating symlink: $link_dir -> $target_dir"
        # Ensure parent directory of link exists
        mkdir -p "$(dirname "$link_dir")"
        ln -s "$target_dir" "$link_dir"
    fi
}

main() {
    echo "============================================================="
    echo "Phase 2b: Model Symlink Creation"
    echo "============================================================="
    
    # 1. Models symlinks (Target: EasyReforge/Model/*, Link: stable-diffusion-webui-reForge/models/*)
    make_symlink "${EASY_MODEL_DIR}/adetailer" "${REFORGE_WEBUI}/models/adetailer"
    make_symlink "${EASY_MODEL_DIR}/ControlNet" "${REFORGE_WEBUI}/models/ControlNet"
    make_symlink "${EASY_MODEL_DIR}/ESRGAN" "${REFORGE_WEBUI}/models/ESRGAN"
    make_symlink "${EASY_MODEL_DIR}/Lora" "${REFORGE_WEBUI}/models/Lora"
    make_symlink "${EASY_MODEL_DIR}/Stable-diffusion" "${REFORGE_WEBUI}/models/Stable-diffusion"
    make_symlink "${EASY_MODEL_DIR}/VAE" "${REFORGE_WEBUI}/models/VAE"
    
    # 2. Extensions symlinks
    make_symlink "${EASY_MODEL_DIR}/wildcards" "${REFORGE_WEBUI}/extensions/sd-dynamic-prompts/wildcards"
    
    # Copy wildcards initial prompt txts if not present
    local src_wildcards="${SCRIPT_DIR}/src"
    local target_wildcards="${EASY_MODEL_DIR}/wildcards"
    if [ ! -f "${target_wildcards}/1girl.txt" ] && [ -f "${src_wildcards}/1girl.txt" ]; then
        cp "${src_wildcards}/1girl.txt" "${target_wildcards}/"
    fi
    if [ ! -f "${target_wildcards}/play.txt" ] && [ -f "${src_wildcards}/play.txt" ]; then
        cp "${src_wildcards}/play.txt" "${target_wildcards}/"
    fi
    
    # 3. Create subdirectories for outputs inside the WebUI directory
    mkdir -p "${REFORGE_WEBUI}/outputs/txt2img-images" \
             "${REFORGE_WEBUI}/outputs/img2img-images" \
             "${REFORGE_WEBUI}/outputs/extras-images" \
             "${REFORGE_WEBUI}/outputs/txt2img-grids" \
             "${REFORGE_WEBUI}/outputs/img2img-grids" \
             "${REFORGE_WEBUI}/log/images"
             
    # 4. Outputs symlink
    # Original Windows logic: call %JUNCTION% ..\OutputReforge outputs
    # This means Target: reForge's internal "outputs" dir, Link: "OutputReforge" in EasyReforge root
    local output_internal="${REFORGE_WEBUI}/outputs"
    local output_reforge="${REFORGE_ROOT}/EasyReforge/OutputReforge"
    make_symlink "$output_internal" "$output_reforge"
    
    echo "Model symlinks created successfully."
}

main "$@"
