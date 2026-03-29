#!/usr/bin/env python3
import os
import re
import csv
from pathlib import Path

def parse_bat_file(bat_path):
    metadata_list = []
    
    helper_mapping = {
        'CIVITAI_MODEL': 'civitai_download',
        'CIVITAI_MODEL_UNZIP': 'civitai_download_unzip',
        'HUGGINGFACE_MODEL': 'huggingface_download',
        'HUGGING_FACE': 'huggingface_download',
        'HUGGING_FACE_HUB': 'huggingface_hub_download',
        'ARIA': 'aria_download',
        'ARIA_MODEL': 'aria_download'
    }
    
    content = bat_path.read_text(encoding='utf-8', errors='ignore')
    
    # max 6 args captured
    call_pattern = re.compile(r'call\s+%([A-Z_]+)%\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)(?:\s+([^\s]+))?(?:\s+([^\s]+))?')
    
    for match in call_pattern.finditer(content):
        helper_key = match.group(1)
        # arg1: 通常は出力ディレクトリのサフィックス (例 `NoobE_Char\` や `.\` や `%~n0\`)
        arg1 = match.group(2).replace('\\', '/').rstrip('/') if match.group(2) not in ['.\\', '.'] else ""
        
        # %~n0 の展開 (バッチファイル名(拡張子なし))
        if '%~n0' in arg1:
            arg1 = arg1.replace('%~n0', bat_path.stem)
            
        arg2 = match.group(3)
        arg3 = match.group(4)
        arg4 = match.group(5) if match.group(5) else ""
        arg5 = match.group(6) if match.group(6) else ""
        
        try:
            rel_path = bat_path.relative_to(Path("Download").resolve().parent / "Download")
        except ValueError:
            rel_path = bat_path
            
        parts = rel_path.parts
        model_type = parts[0] if len(parts) > 1 and parts[0] != "All" else "Unknown"
        if rel_path.parent.name in ["Stable-diffusion", "Lora", "ControlNet", "VAE", "ESRGAN", "adetailer", "wildcards"]:
            model_type = rel_path.parent.name
            
        # フォルダがカテゴリ直下でない場合（例 Lora/NoobE_Char）
        base_category = parts[0]
        
        helper_name = helper_mapping.get(helper_key, helper_key.lower())
        
        # 各種IDの抽出
        civitai_model_id = ""
        civitai_version_id = ""
        hf_model_id = ""
        direct_url = ""
        
        if helper_name in ['civitai_download', 'civitai_download_unzip']:
            civitai_model_id = arg3
            civitai_version_id = arg4
        elif helper_name in ['huggingface_download', 'huggingface_hub_download']:
            # huggingface_hub の場合は、arg2がrepo (yyy/songMix)、arg3がタイプ、arg4がフィルタ など変則的になるが、
            # とりあえず リポジトリID は arg2 か arg3 のどちらかに スラッシュ入り で存在する
            if '/' in arg2 and not arg2.endswith('.safetensors'):
                hf_model_id = arg2
            elif '/' in arg3:
                hf_model_id = arg3
        elif 'aria' in helper_name:
            if arg3.startswith('http'):
                direct_url = arg3
            elif arg4.startswith('http'):
                direct_url = arg4
            elif arg5.startswith('http'):
                direct_url = arg5

        # 不要な末尾の ? を除去 (例: file.safetensors?)
        arg2 = arg2.rstrip('?')
        arg3 = arg3.rstrip('?')
        arg4 = arg4.rstrip('?')
        
        output_dir = f"{base_category}/{arg1}".strip('/') if arg1 else base_category
        
        metadata={
            'script_name': str(rel_path).replace('.bat', '.sh'),
            'model_type': base_category,
            'download_method': helper_name,
            'civitai_model_id': civitai_model_id,
            'civitai_version_id': civitai_version_id,
            'huggingface_model_id': hf_model_id,
            'direct_url': direct_url,
            'output_directory': output_dir,
            'helper_library': f"{helper_name}.sh",
            'filename': arg2,   # Note: For HUGGING_FACE_HUB this might be a repo name instead of filename
            'param1': arg3,
            'param2': arg4,
            'param3': arg5
        }
        metadata_list.append(metadata)
        
    return metadata_list

def main():
    base_dir = Path("/home/ytsubame/src/EasyReforge-Ubuntu/Download")
    csv_file = Path("/home/ytsubame/src/EasyReforge-Ubuntu/Download/metadata.csv")
    
    all_metadata = []
    
    for bat_path in base_dir.rglob("*.bat"):
        if "lib" in bat_path.parts or bat_path.name in ["CivitaiModel.bat", "Aria.bat", "huggingface.bat"]:
            continue
                
        content = bat_path.read_text(encoding='utf-8', errors='ignore')
        
        # call がある行のみを処理するため一旦これで弾く
        if "call %" not in content:
            continue
            
        extracted = parse_bat_file(bat_path)
        all_metadata.extend(extracted)
        
    unique_metadata_dict = {}
    for m in all_metadata:
        key = (m['script_name'], m['output_directory'], m['filename'], m['param1'])
        unique_metadata_dict[key] = m
        
    fieldnames = [
        'script_name', 'model_type', 'download_method', 
        'civitai_model_id', 'civitai_version_id', 'huggingface_model_id', 
        'direct_url', 'output_directory', 'helper_library',
        'filename', 'param1', 'param2', 'param3'
    ]
    
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in sorted(unique_metadata_dict.values(), key=lambda x: x['script_name']):
            writer.writerow(row)
            
    print(f"Extraction complete! Found {len(unique_metadata_dict)} download declarations.")
    print(f"Saved to {csv_file}")

if __name__ == "__main__":
    main()
