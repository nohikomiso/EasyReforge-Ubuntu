#!/usr/bin/env python3
import csv
import os
import sys
from collections import defaultdict
from pathlib import Path

def generate_scripts(csv_path):
    download_dir = Path(csv_path).parent
    lib_dir = download_dir / "lib"
    
    if not os.path.exists(csv_path):
        print(f"Error: {csv_path} not found.")
        sys.exit(1)

    scripts_data = defaultdict(list)
    
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            script_name = row['script_name']
            if not script_name:
                continue
            scripts_data[script_name].append(row)

    print(f"Found {len(scripts_data)} unique scripts in metadata.")

    generated_count = 0
    for script_rel_path, rows in scripts_data.items():
        script_path = download_dir / script_rel_path
        script_path.parent.mkdir(parents=True, exist_ok=True)

        # Calculate relative path to lib/
        depth = len(Path(script_rel_path).parts) - 1
        rel_lib_path = "../" * depth + "lib"

        used_libraries = set()
        for row in rows:
            used_libraries.add(row['helper_library'])
        
        # Always use common.sh
        used_libraries.add("common.sh")

        content = []
        content.append("#!/bin/bash")
        content.append("set -euo pipefail")
        content.append("trap 'echo \"Error on line $LINENO\"; exit 1' ERR")
        content.append("")
        content.append('SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"')
        
        # Source libraries
        # Order: common.sh first, then others
        content.append(f'# shellcheck disable=SC1091')
        content.append(f'source "${{SCRIPT_DIR}}/{rel_lib_path}/common.sh"')
        for lib in sorted(list(used_libraries)):
            if lib == "common.sh":
                continue
            content.append(f'# shellcheck disable=SC1091')
            content.append(f'source "${{SCRIPT_DIR}}/{rel_lib_path}/{lib}"')
        
        content.append("")

        for row in rows:
            method = row['download_method']
            # Map method to shell function
            func_name = method
            
            # Prepare arguments
            model_dir = row['output_directory']
            filename = row['filename']
            params = []
            
            p1 = row.get('param1', '').strip()
            p2 = row.get('param2', '').strip()
            p3 = row.get('param3', '').strip()

            if method == 'civitai_download' or method == 'civitai_download_unzip':
                # model_dir, filename, model_id, version_id
                params = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"', f'"{p2}"']
            elif method == 'huggingface_download':
                # model_dir, filename, model_id, [hf_filename]
                params = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"']
                if p2:
                    params.append(f'"{p2}"')
            elif method == 'huggingface_hub_download':
                # model_dir, filename, model_id
                params = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"']
            elif method == 'aria_download':
                # model_dir, filename, url
                params = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"']
            else:
                print(f"Warning: Unknown download method '{method}' in {script_rel_path}")
                continue

            content.append(f'{func_name} {" ".join(params)}')

        with open(script_path, "w", encoding='utf-8') as f:
            f.write("\n".join(content) + "\n")
        
        os.chmod(script_path, 0o755)
        generated_count += 1

    print(f"Successfully generated {generated_count} scripts.")

if __name__ == "__main__":
    # [Portability Fix] Use relative paths from script location
    csv_file = os.path.join(os.path.dirname(__file__), '..', 'metadata.csv')
    generate_scripts(csv_file)
