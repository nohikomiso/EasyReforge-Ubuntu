#!/usr/bin/env python3
import csv
import os
import sys
import subprocess
import argparse
from pathlib import Path

def get_script_dir():
    return Path(__file__).resolve().parent

def download_engine(csv_path, filter_type=None, filter_tag=None, filter_name=None):
    lib_dir = get_script_dir()
    download_root = lib_dir.parent
    
    if not os.path.exists(csv_path):
        print(f"Error: {csv_path} not found.")
        sys.exit(1)

    is_dry_run = os.environ.get("DRY_RUN") == "1"
    
    executed_count = 0
    skipped_count = 0
    
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Filtering logic
            if filter_type and row['model_type'] != filter_type:
                continue
            
            if filter_tag:
                tags = row.get('tags', '').split(';')
                if filter_tag not in tags:
                    continue
            
            if filter_name and filter_name not in row['script_name']:
                continue

            # Execution logic
            method = row['download_method']
            lib = row['helper_library']
            model_dir = row['output_directory']
            filename = row['filename']
            p1 = row.get('param1', '').strip()
            p2 = row.get('param2', '').strip()
            p3 = row.get('param3', '').strip()

            # Map parameters based on method (mirrors generate_scripts.py logic)
            func_args = []
            if method in ['civitai_download', 'civitai_download_unzip']:
                func_args = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"', f'"{p2}"']
            elif method == 'huggingface_download':
                func_args = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"']
                if p2: func_args.append(f'"{p2}"')
            elif method in ['huggingface_hub_download', 'aria_download']:
                func_args = [f'"{model_dir}"', f'"{filename}"', f'"{p1}"']
            else:
                print(f"Warning: Skipping unknown method '{method}' for {row['script_name']}")
                skipped_count += 1
                continue

            bash_cmd = f'source "{lib_dir}/common.sh" && source "{lib_dir}/{lib}" && {method} {" ".join(func_args)}'
            
            print(f"[{'DRY-RUN' if is_dry_run else 'EXEC'}] {row['script_name']} ({method})")
            
            if not is_dry_run:
                try:
                    # Run in download_root to keep relative paths consistent
                    subprocess.run(['bash', '-c', bash_cmd], cwd=download_root, check=True)
                    executed_count += 1
                except subprocess.CalledProcessError as e:
                    print(f"Error: Failed to download {row['script_name']}")
                    # continue to next instead of exiting? (Standard batch behavior continues)
            else:
                executed_count += 1

    print(f"\nEngine finished. Executed/Queued: {executed_count}, Skipped: {skipped_count}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="EasyReforge Download Engine")
    parser.add_argument("--type", help="Filter by model category (e.g. Lora, ControlNet)")
    parser.add_argument("--tag", help="Filter by variant tag (e.g. minimum, standard)")
    parser.add_argument("--name", help="Filter by script name substring")
    parser.add_argument("--csv", default=str(get_script_dir().parent / "metadata.csv"), help="Path to metadata.csv")
    
    args = parser.parse_args()
    
    download_engine(args.csv, filter_type=args.type, filter_tag=args.tag, filter_name=args.name)
