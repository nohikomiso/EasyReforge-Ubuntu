#!/usr/bin/env python3
import os
import sys
import argparse
import subprocess
import shutil
from pathlib import Path

def download_civitai_model(model_version_id, output_dir, filename, api_token=None):
    """
    civitai-model-downloader を使用してモデルを物理的にダウンロードする。
    """
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    target_file = output_path / filename
    
    # --- SMART SEARCH: 再帰的なチェックを追加 (サブフォルダ内も探索) ---
    # カテゴリのトップ（Stable-diffusion, Lora等）を特定し、その配下を再帰的にスキャンする
    category_top = output_path
    # 'models' フォルダに到達するまで、または一定の深さまで親を辿る
    for _ in range(3):
        if category_top.parent.name == 'models' or category_top.name in ['Stable-diffusion', 'Lora', 'ControlNet', 'VAE', 'ESRGAN', 'adetailer', 'wildcards']:
            break
        category_top = category_top.parent

    # 1. 指定の場所に直接存在するか？
    if target_file.exists():
        print(f"INFO: Already exists at target: {target_file}")
        return True
        
    # 2. カテゴリのサブフォルダ内に存在するか？ (rglob)
    # これによりユーザー独自のサブフォルダ整理を許容し、二重ダウンロードを防ぐ
    print(f"INFO: Checking subdirectories in {category_top} for '{filename}'...")
    found_any = list(category_top.rglob(filename))
    if found_any:
        print(f"INFO: Found existing file in subfolder: {found_any[0]}")
        return True

    # コマンドの構築
    # civitai-downloader-cli download <version_id> --local-dir <output_dir>
    # 注意: ライブラリは元のファイル名で保存するため、後でリネームする
    cmd = [
        "uv", "run", "civitai-downloader-cli", "download",
        str(model_version_id),
        "--local-dir", str(output_path)
    ]
    
    env = os.environ.copy()
    if api_token:
        # 環境変数経由でトークンを渡す
        env["CIVITAI_API_TOKEN"] = api_token

    print(f"INFO: Running: {' '.join(cmd)}")
    
    # ダウンロード前のディレクトリ構成を記録
    pre_files = set(output_path.glob("*"))
    
    try:
        # 実際にコマンドを実行
        result = subprocess.run(cmd, env=env, check=True, capture_output=True, text=True)
        print(result.stdout)
        
        # ダウンロード後に増えたファイルを特定
        post_files = set(output_path.glob("*"))
        new_files = post_files - pre_files
        
        if not new_files:
            # 既に別名で存在していた可能性
            print("INFO: No new file detected. Checking if download was successful.")
            if target_file.exists(): return True
            return False

        # 最新のファイルをリネーム
        downloaded_file = max(new_files, key=lambda f: f.stat().st_mtime)
        if downloaded_file.name != filename:
            print(f"INFO: Renaming {downloaded_file.name} to {filename}")
            downloaded_file.rename(target_file)
            
        print(f"INFO: Download and rename complete: {target_file}")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"ERROR: {e.stderr}", file=sys.stderr)
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("model_version_id")
    parser.add_argument("output_dir")
    parser.add_argument("filename")
    parser.add_argument("--token", default=os.getenv("CIVITAI_API_TOKEN"))
    args = parser.parse_args()
    
    success = download_civitai_model(args.model_version_id, args.output_dir, args.filename, args.token)
    sys.exit(0 if success else 1)
