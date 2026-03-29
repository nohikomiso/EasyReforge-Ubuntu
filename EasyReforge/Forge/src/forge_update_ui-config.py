import json
import os
import sys


class ForgeUiConfig:
    DEBUG_MODE = False

    def __init__(self, cfg_path):
        self.updaters = {
            "0.0.0": self.update_0_0_0,
        }

        if not os.path.exists(cfg_path):
            with open(cfg_path, "w", encoding="utf-8") as f:  # BOM 不可
                json.dump(
                    {},
                    f,
                )

        with open(cfg_path, "r+", encoding="utf-8") as f:
            cfg = json.load(f)
            
            if "easy_forge_ui-config_version" not in cfg:  # ファイル生成なし対策
                cfg["easy_forge_ui-config_version"] = "0.0.0"

            if self.DEBUG_MODE:
                cfg["easy_forge_ui-config_version"] = "0.0.0"

            if self.update(cfg):
                f.seek(0)
                json.dump(cfg, f, indent=4)
                f.truncate()

    def update(self, cfg):
        version = cfg["easy_reforge_ui-config_version"]
        if version not in self.updaters:
            return False
        self.updaters[version](cfg)
        self.update(cfg)
        return True

    def update_0_0_0(self, cfg):
        cfg["easy_reforge_ui-config_version"] = "0.1.0"

        cfg["txt2img/Prompt/value"] = (
            "1girl, rem \\(re:zero\\), re:zero kara hajimeru isekai seikatsu,\nofficial style,\nsanta costume, indoors,\n<lora:NoobV065sHyperDmd:1> masterpiece, best quality, very aesthetic, absurdres, newest, safe\n# 起動時の設定を変更したい場合は、設定を変更して Settings - Defaults の Apply"
        )

        cfg["txt2img/Batch count/maximum"] = 999
        cfg["txt2img/Batch size/maximum"] = 16

        # cfg["txt2img/Hires. fix/value"] = True
        # cfg["txt2img/Upscaler/value"] = "Latent (nearest-exact)"
        # cfg["txt2img/Denoising strength/value"] = 0.6
        # cfg["txt2img/Upscale by/value"] = 1.5
        # cfg["txt2img/Hires CFG Scale/value"] = 1.0

        # cfg["txt2img/Width/value"] = 896
        # cfg["txt2img/Height/value"] = 1152
        # cfg["txt2img/CFG Scale/value"] = 1.0

        # cfg["customscript/sampler.py/txt2img/Sampling method/value"] = "LCM"
        # cfg["customscript/sampler.py/txt2img/Schedule type/value"] = "SGM Uniform"
        # cfg["customscript/sampler.py/txt2img/Sampling steps/value"] = 4

        # cfg["customscript/xyz_grid.py/txt2img/Include Sub Grids/value"] = True

        cfg["customscript/tipo.py/txt2img/Prompt Format/value"] = "tag only (DTG mode)"
        cfg["customscript/tipo.py/txt2img/Seed for upsampling tags/value"] = 0
        cfg["customscript/tipo.py/txt2img/Model/value"] = "KBlueLeaf/TIPO-500M-ft | TIPO-500M-ft-F16.gguf"
        cfg["customscript/tipo.py/img2img/Model/value"] = "KBlueLeaf/TIPO-500M-ft | TIPO-500M-ft-F16.gguf"
        cfg["customscript/tipo.py/txt2img/Ban tags/value"] = (
            "background, greyscale, monochrome, hair, eyes, multiple view, censor, pubic"
        )

        cfg["customscript/negpip.py/txt2img/Active/value"] = True
        cfg["customscript/cdtuner.py/txt2img/Active/value"] = True
        cfg["customscript/lora_block_weight.py/txt2img/Active/value"] = True


if __name__ == "__main__":
    forge_config = ForgeUiConfig(sys.argv[1])
