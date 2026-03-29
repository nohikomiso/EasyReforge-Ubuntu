import csv
import os

def tag_metadata(csv_file):
    # Lists of script names (relative to Download/) that belong to variants
    # Note: .sh is used because Task 4.1 already converted them to .sh names in the CSV
    
    # Common Minimum (as per NoobAiCommon_Minimum.bat)
    common_min = [
        "adetailer/bbox/face_yolov9c.sh",
        "adetailer/bbox/foot_yolov8x_v2.sh",
        "adetailer/bbox/hand_yolov9c.sh",
        "adetailer/segm/AnzhcBreasts-v1-1024-seg.sh",
        "adetailer/segm/AnzhcEyes-seg.sh",
        "adetailer/segm/AnzhcFace-v2-640-seg.sh",
        "adetailer/segm/AnzhcFace-v2-768MS-seg.sh",
        "adetailer/segm/AnzhcFace-v2-1024-seg.sh",
        "adetailer/segm/AnzhcHead-seg.sh",
        "adetailer/segm/AnzhcHeadHair-seg.sh",
        "adetailer/segm/PitHandDetailer-v1b-seg.sh",
        "ControlNet/Sdxl/Inpaint_Kataragi.sh",
        "ControlNet/Sdxl/AnyTest_Dim64_v10.sh",
        "ControlNet/NoobE/NoobE_Tile.sh",
        "ControlNet/NoobE/NoobE_Inpaint.sh",
        "Lora/Noob_Boost/NoobV065sHyperDmd.sh",
        "Lora/Sdxl_Boost/dmd2_sdxl_4step.sh",
        "Lora/Sdxl_Boost/Hyper_sdxl_8step.sh",
        "wildcards/noob_1girl.sh",
        "wildcards/tipo_1girl.sh",
        "wildcards/tipo_play.sh",
        "wildcards/tipo_location.sh"
    ]
    
    # EpsilonPred Specific Minimum
    eps_min = common_min + [
        "Stable-diffusion/NoobE/copycatNoob_v11.sh",
        "Stable-diffusion/NoobE/HarmoniqMixSpoE_v11.sh"
    ]
    
    # VPred Specific Minimum
    v_min = common_min + [
        "Stable-diffusion/NoobV/HarmoniqMixSpo_v30.sh",
        "Stable-diffusion/NoobV/CatTowerV_v17.sh"
    ]
    
    combined_min = list(set(eps_min + v_min))
    
    rows = []
    with open(csv_file, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames + ['tags']
        for row in reader:
            tags = []
            script = row['script_name']
            
            # Category match for ESRGAN (Minimum calls All/ESRGAN.bat)
            if row['model_type'] == 'ESRGAN':
                tags.append('minimum')
                tags.append('standard')
            
            # VAE Sdxl (Commonly part of standard models)
            if row['model_type'] == 'VAE' and 'Sdxl' in script:
                tags.append('standard')

            # Check for direct matches in variants
            if script in combined_min:
                tags.append('minimum')
                tags.append('standard')
            elif "NoobE" in script or "NoobV" in script:
                # Most NoobE/NoobV models are considered 'standard'
                if 'standard' not in tags:
                    tags.append('standard')
            
            row['tags'] = ';'.join(tags)
            rows.append(row)
            
    # Write back to metadata.csv
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    
    print(f"Metadata tagging complete. Added 'tags' column to {csv_file}.")

if __name__ == '__main__':
    tag_metadata('Download/metadata.csv')
