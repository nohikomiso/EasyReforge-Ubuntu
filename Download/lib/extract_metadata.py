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
    
    # 行単位で処理して改行を跨がないようにする
    # call %HEPLER% <arg1> <arg2> <arg3> [arg4] [arg5]
    call_pattern = re.compile(r'call\s+%([A-Z_]+)%(?:\s+([^\s]+))?(?:\s+([^\s]+))?(?:\s+([^\s]+))?(?:\s+([^\s]+))?(?:\s+([^\s]+))?')
    
    for line in content.splitlines():
        line = line.strip()
        if not line.startswith('call %'):
            continue
            
        match = call_pattern.search(line)
        if not match:
            continue
            
        helper_key = match.group(1)
        
        # 不要なヘルパー(JUNCTION, EXTRACT_ZIPなど)は除外
        if helper_key not in helper_mapping:
            continue
            
        arg1 = match.group(2) if match.group(2) else ""
        arg2 = match.group(3) if match.group(3) else ""
        arg3 = match.group(4) if match.group(4) else ""
        arg4 = match.group(5) if match.group(5) else ""
        arg5 = match.group(6) if match.group(6) else ""
        
        # arg1: 通常は出力ディレクトリのサフィックス (例 `NoobE_Char\` や `.\` や `%~n0\`)
        arg1 = arg1.replace('\\', '/').rstrip('/') if arg1 not in ['.\\', '.', ''] else ""
        
        # %~n0 の展開 (バッチファイル名(拡張子なし))
        if '%~n0' in arg1:
            arg1 = arg1.replace('%~n0', bat_path.stem)
            
        try:
            rel_path = bat_path.relative_to(Path("Download").resolve().parent / "Download")
        except ValueError:
            rel_path = bat_path
            
        parts = rel_path.parts
        base_category = parts[0] if len(parts) > 1 and parts[0] != "All" else "Unknown"
        if rel_path.parent.name in ["Stable-diffusion", "Lora", "ControlNet", "VAE", "ESRGAN", "adetailer", "wildcards"]:
            base_category = rel_path.parent.name
            
        helper_name = helper_mapping.get(helper_key, helper_key.lower())
        
        # 各種IDの抽出
        civitai_model_id = ""
        civitai_version_id = ""
        hf_model_id = ""
        direct_url = ""
        
        # civitai_download 系は arg3 が model_id, arg4 が version_id となる場合が多い (arg2=filename)
        if helper_name in ['civitai_download', 'civitai_download_unzip']:
            civitai_model_id = arg3
            civitai_version_id = arg4
        # huggingface 系
        elif helper_name in ['huggingface_download', 'huggingface_hub_download']:
            # repo は通常 arg2(ファイル名) と間違えて arg3 にあるか、arg2 に repo で arg3 に model となるケースがある
            if '/' in arg2 and not arg2.endswith('.safetensors') and not arg2.endswith('.pth') and not arg2.endswith('.pt'):
                hf_model_id = arg2
            elif '/' in arg3:
                hf_model_id = arg3
        # aria_download 系
        elif 'aria_download' in helper_name:
            if arg3.startswith('http'):
                direct_url = arg3
            elif arg4.startswith('http'):
                direct_url = arg4
            elif arg5.startswith('http'):
                direct_url = arg5

        # 不要な末尾の ? を除去
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
            'filename': arg2,
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
        if "lib" in bat_path.parts or bat_path.name in ["CivitaiModel.bat", "Aria.bat", "huggingface.bat", "CivitaiModelUnzip.bat"]:
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
