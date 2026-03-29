import json
import os
import sys
from datetime import datetime


class ForgeConfig:
    DEBUG_MODE = False

    def __init__(self, cfg_path):
        self.updaters = {
            "0.0.0": self.update_0_0_0,
        }
        self.styles_csv_path = os.path.join(os.path.dirname(cfg_path), "styles.csv")

        if not os.path.exists(cfg_path):
            with open(cfg_path, "w", encoding="utf-8") as f:  # BOM 不可
                json.dump(
                    {  # InfiniteImageBrowsing が WebUI 上での初回保存前に参照するため
                        "outdir_samples": "",
                        "outdir_txt2img_samples": "outputs\\txt2img-images",
                        "outdir_img2img_samples": "outputs\\img2img-images",
                        "outdir_extras_samples": "outputs\\extras-images",
                        "outdir_grids": "",
                        "outdir_txt2img_grids": "outputs\\txt2img-grids",
                        "outdir_img2img_grids": "outputs\\img2img-grids",
                        "outdir_save": "log\\images",
                        "outdir_init_images": "outputs\\init-images",
                    },
                    f,
                )

        with open(cfg_path, "r+", encoding="utf-8") as f:
            cfg = json.load(f)
            
            if "easy_forge_config_version" not in cfg:  # ファイル生成なし対策
                cfg["easy_forge_config_version"] = "0.0.0"

            if self.DEBUG_MODE:
                cfg["easy_forge_config_version"] = "0.0.0"

            if self.update(cfg):
                f.seek(0)
                json.dump(cfg, f, indent=4)
                f.truncate()

    def backup_styles_csv(self):
        if os.path.exists(self.styles_csv_path):
            styles_path, ext = os.path.splitext(self.styles_csv_path)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M_%S%f")
            os.rename(self.styles_csv_path, f"{styles_path}_{timestamp}{ext}")

    def update(self, cfg):
        version = cfg["easy_reforge_config_version"]
        if version not in self.updaters:
            return False
        self.updaters[version](cfg)
        self.update(cfg)
        return True

    def update_0_0_0(self, cfg):
        cfg["easy_reforge_config_version"] = "0.1.0"

        cfg["export_for_4chan"] = False
        cfg["lora_preferred_name"] = "Filename"
        cfg["ui_extra_networks_tab_reorder"] = "LoRA,Checkpoints,Textual Inversion"
        cfg["emphasis"] = "No norm"
        cfg["disable_weights_auto_swap"] = False
        cfg["lora_show_all"] = True
        cfg["extra_networks_tree_view_default_width"] = 300
        cfg["hires_fix_show_sampler"] = True
        cfg["hires_fix_show_prompts"] = True
        cfg["infotext_skip_pasting"] = ["Emphasis"]
        cfg["interrupt_after_current"] = False

        cfg["bilingual_localization_file"] = "ja_JP"
        cfg["dp_wildcard_manager_no_sort"] = True
        cfg["tac_showWikiLinks"] = True
        cfg["tipo_no_extra_input"] = True


if __name__ == "__main__":
    forge_config = ForgeConfig(sys.argv[1])
