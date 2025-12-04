# EasyReforge Ubuntu Migration - Complete Planning Guide

**Status**: Planning Complete ✅
**Last Updated**: 2025-12-04
**Total Scope**: 237 batch files → shell scripts conversion
**Estimated Duration**: 10-12 weeks (full) or 4-5 weeks (core only)

---

# Part 1: Phase Overview (Quick Reference)

## Phase 1: Foundation Scripts (Weeks 1-2)

**Goal**: Create bootstrap installer that works via `curl | bash`

**Helper Libraries**:
- `github.sh` - Git clone/pull operations
- `python.sh` - Python venv management

**Core Scripts** (5 files):
- `easyreforge_installer.sh` ⭐ **START HERE**
- `update.sh`
- `setup.sh`

**Deliverables**: One-command installation working on Ubuntu
**Time**: 4-6 hours each script

---

## Phase 2: Core Environment (Weeks 3-4)

**Goal**: Fully functional reForge WebUI installation

**Helper Libraries**:
- `link_helper.sh` - Symlink creation and validation

**Core Scripts** (7 files):
- `reforge.sh` ⭐ **CRITICAL - 40-50 hours**
- `reforge_extension.sh` (13 GitHub extensions)
- `reforge_link.sh` (model directory linking)
- `reforge_config.sh` (config migration)
- `reforge_ui_config.sh` (UI config)
- Root launcher `reforge.sh`

**Critical Cautions**:
1. PyTorch platform-specific wheels (Linux manylinux2014_x86_64)
2. SageAttention wheel compatibility
3. Virtual environment activation differences
4. Symlink semantics (Linux vs Windows junctions)

**Deliverables**: WebUI launches and can generate images
**Time**: 50-60+ hours

---

## Phase 3: Download Helpers (Weeks 5-6)

**Goal**: Foundation for 165+ model download scripts

**Helper Libraries** (7 files):
1. `common.sh` (error handling, logging)
2. `civitai_download.sh` (66 scripts depend)
3. `huggingface_download.sh` (59 scripts depend)
4. `civitai_download_unzip.sh` (21 scripts)
5. `huggingface_hub_download.sh` (4 scripts)
6. `aria_download.sh` (4 scripts)
7. `recursive_call.sh` (directory recursion)

**Metadata Tool**:
- Parse all 176 .bat files → CSV

**Deliverables**: 7 helper libraries tested, metadata extracted
**Time**: 30-40 hours

---

## Phase 4: Model Script Generation (Weeks 7-8)

**Goal**: 165+ automated download scripts + validation

**Tasks**:
1. Generate 165+ model scripts (automated from metadata)
2. Convert 20 meta-scripts (semi-automated)
3. Convert 2 composition scripts (manual)
4. Validate with shellcheck + dry-run mode

**Deliverables**: All 176+ scripts generated, tested, validated
**Time**: 30-40 hours

---

## Phase 2b: Model Linking (Weeks 9-10, Parallel)

**Goal**: Symlink templates for user model directories

**Scripts** (14 files, 7 categories × 2 types):
- `link_input.sh` - External source linking
- `link_output.sh` - Output destination linking

**Categories**:
- Stable-diffusion, Lora, ControlNet, VAE, ESRGAN, adetailer, wildcards

**Deliverables**: All symlinks created, WebUI can access models
**Time**: 15-20 hours

---

## Phase 5: Optional Launchers (Weeks 11-12)

**Goal**: Complete feature parity + end-to-end testing

**Scripts** (24+ files):
- 8 Reforge launcher variants
- 8 LLM inference scripts
- Optional extension launchers
- End-to-end testing on fresh Ubuntu VM

**Deliverables**: All 237 scripts converted, tested, ready for release
**Time**: 20-25 hours

---

---

# Part 2: Complete Script Inventory (All 237 Files)

## Phase 1: Foundation (5 scripts)

### Bootstrap & Orchestration
```
Total: 5 scripts
├─ EasyReforge/easyreforge_installer.sh (MAIN ENTRY POINT)
├─ EasyReforge/setup.sh
├─ EasyReforge/update.sh
├─ EasyReforge/src/lib/github.sh (helper)
└─ EasyReforge/src/lib/python.sh (helper)
```

---

## Phase 2: Core Environment (9 scripts)

### reForge Setup
```
Total: 9 scripts
├─ EasyReforge/Reforge/reforge.sh ⭐ CRITICAL
├─ EasyReforge/Reforge/reforge_extension.sh
├─ EasyReforge/Reforge/reforge_config.sh
├─ EasyReforge/Reforge/reforge_ui_config.sh
├─ EasyReforge/Reforge/reforge_link.sh
├─ EasyReforge/Reforge/src/link_helper.sh (helper)
├─ EasyReforge/reforge.sh (root launcher)
├─ EasyReforge/Reforge_NoOptions.sh (main launcher)
└─ EasyReforge/Reforge_FastLaunch.sh (optional)
```

---

## Phase 3: Download Helpers (7 scripts)

### Download Infrastructure
```
Total: 7 scripts (in Download/lib/)
├─ common.sh (all others depend)
├─ civitai_download.sh (66 scripts use)
├─ huggingface_download.sh (59 scripts use)
├─ civitai_download_unzip.sh (21 scripts use)
├─ huggingface_hub_download.sh (4 scripts use)
├─ aria_download.sh (4 scripts use)
└─ recursive_call.sh (meta-scripts use)
```

---

## Phase 4: Model Download Scripts (176 scripts)

### Stable Diffusion Models (48 scripts)

**Categories**:
- NoobE/ (Epsilon-prediction)
  - AniKawa.sh, copycatNoob.sh, HarmoniqMixSpoE.sh, ...
- NoobV/ (V-prediction)
  - [Same models as NoobE but V-pred variant]
- Realistic/ (photorealistic)
  - [Realistic model variants]

**Pattern**: Each script calls appropriate helper (civitai_download.sh or huggingface_download.sh)

### LoRA Models (36 scripts)

**Categories**:
- Char/ (character LoRAs)
- Style/ (style LoRAs)
- Tech/ (technical LoRAs)

**Pattern**: Similar to Stable-diffusion, organized by category

### ControlNet Models (27 scripts)

**Categories**:
- Depth, Canny, Pose, Inpaint, LineArt, etc.

### VAE Models (7 scripts)

**Examples**:
- VAE_FP16_Fix.sh, VAE_VAE_Approx.sh, etc.

### ESRGAN Models (7 scripts)

**Examples**:
- ESRGAN_x4plus.sh, SwinIR_x4.sh, etc.

### adetailer Models (9 scripts)

**Examples**:
- adetailer_face.sh, adetailer_hand.sh, etc.

### Wildcard Collections (13 scripts)

**Examples**:
- wildcard_anime.sh, wildcard_realistic.sh, etc.

### Other Models (29 scripts)

**Including**: Inpainting, Upscaling, Misc models

### Total Model Scripts: 176 scripts
```
├─ Stable-diffusion/: 48 scripts
├─ Lora/: 36 scripts
├─ ControlNet/: 27 scripts
├─ VAE/: 7 scripts
├─ ESRGAN/: 7 scripts
├─ adetailer/: 9 scripts
├─ wildcards/: 13 scripts
└─ Other categories: 29 scripts
```

---

## Meta-Scripts & Orchestrators (20 scripts)

### Download/All/ (12 scripts)
```
├─ All/AllStable-diffusion_Minimum.sh
├─ All/AllStable-diffusion_Standard.sh
├─ All/AllStable-diffusion_Full.sh
├─ All/AllLora_Minimum.sh
├─ All/AllLora_Standard.sh
├─ All/AllControlNet.sh
├─ All/AllVAE.sh
├─ All/AllESRGAN.sh
├─ All/Alladetailer.sh
├─ All/AllWildcards.sh
├─ All/AllModels_Minimum.sh
└─ All/AllModels_Full.sh
```

Pattern: Each calls recursive_call.sh to execute all scripts in category

### Download/src/ (2 scripts)
```
├─ NoobAiCommon_Minimum.sh (30+ chained calls)
└─ NoobAiCommon_Standard.sh (7+ calls)
```

Pattern: Manual orchestration of common model sets

### Root Level (6 scripts)
```
├─ NoobAiEpsilonPred_Minimum.sh
├─ NoobAiEpsilonPred_Standard.sh
├─ NoobAiVpred_Minimum.sh
├─ NoobAiVpred_Standard.sh
├─ Download_AllModels_Minimum.sh
└─ Download_AllModels_Full.sh
```

---

## Phase 2b: Model Linking (14 scripts)

### Link Scripts (14 total, 7 categories × 2 types)

**Stable-diffusion/**:
```
├─ link_input.sh (link external sources)
└─ link_output.sh (link output destinations)
```

**Replicated to 6 more categories**:
- Lora/link_input.sh, Lora/link_output.sh
- ControlNet/link_input.sh, ControlNet/link_output.sh
- VAE/link_input.sh, VAE/link_output.sh
- ESRGAN/link_input.sh, ESRGAN/link_output.sh
- adetailer/link_input.sh, adetailer/link_output.sh
- wildcards/link_input.sh, wildcards/link_output.sh

---

## Phase 5: Optional Launchers & Utilities (24+ scripts)

### Reforge Launchers (8 scripts)
```
├─ Reforge_FastLaunch.sh (optimized)
├─ Reforge_NoOptions.sh (minimal)
├─ Reforge_DarkTheme.sh (theme variant)
├─ Reforge_LowVRAM.sh (memory optimization)
├─ Reforge_CPU_Only.sh (CPU mode)
├─ Reforge_RTX40Series.sh (GPU specific)
├─ Reforge_RTX30Series.sh (GPU specific)
└─ Reforge_A100.sh (high-end GPU)
```

### A1111 Variants (3 scripts) - Optional
```
├─ A1111_Installer.sh
├─ A1111_Setup.sh
└─ A1111_Launch.sh
```

### Forge Variants (3 scripts) - Optional
```
├─ Forge_Installer.sh
├─ Forge_Setup.sh
└─ Forge_Launch.sh
```

### LLM Inference (8 scripts)
```
├─ llm_inference_base.sh
├─ llm_inference_4bit.sh
├─ llm_inference_8bit.sh
├─ llm_inference_16bit.sh
├─ llm_chat_interface.sh
├─ llm_text_generation.sh
├─ llm_image_captioning.sh
└─ llm_object_detection.sh
```

### Utilities & Extras (2+ scripts)
```
├─ GenImageViewer.sh
├─ sample_generation.sh
└─ ...
```

---

## Summary: 237+ Total Scripts

```
Phase 1 (Foundation):     5 scripts
Phase 2 (Core):          9 scripts
Phase 3 (Download Helpers): 7 scripts
Phase 4 (Model Scripts): 176 scripts (165 models + 20 meta + 2 manual)
Phase 2b (Linking):      14 scripts
Phase 5 (Launchers):     24+ scripts
                         ─────────────
TOTAL:                   235+ scripts*

*Count includes helpers, excludes non-executable configs
```

---

## Implementation Timeline

```
WEEK 1-2: PHASE 1
├─ Helper: github.sh (3-4 hrs)
├─ Helper: python.sh (1-2 hrs)
├─ Core: easyreforge_installer.sh (4-6 hrs) ⭐ START
├─ Core: update.sh (2-3 hrs)
└─ Core: setup.sh (2-3 hrs)
Total: ~15-20 hours

WEEK 3-4: PHASE 2
├─ Helper: link_helper.sh (4-6 hrs)
├─ Core: reforge.sh (40-50 hrs) ⭐ CRITICAL
├─ Core: reforge_extension.sh (6-8 hrs)
├─ Core: reforge_link.sh (6-8 hrs)
├─ Core: Config scripts (3-4 hrs)
└─ Core: Launchers (2-3 hrs)
Total: ~60-75 hours

WEEK 5-6: PHASE 3
├─ Helpers: 7 download libraries (25-35 hrs)
└─ Tool: Metadata extraction (4-6 hrs)
Total: ~30-40 hours

WEEK 7-8: PHASE 4
├─ Generated scripts (165 scripts, 1-2 days)
├─ Meta-scripts (20 scripts, 2-3 days)
├─ Manual scripts (2 scripts, 1-2 days)
└─ Validation & testing (3-5 days)
Total: ~30-40 hours

WEEK 9-10: PHASE 2b (PARALLEL)
├─ link_input.sh template (4-5 hrs)
├─ link_output.sh template (3-4 hrs)
├─ Replication to 7 categories (2-3 hrs)
└─ Testing (3-4 hrs)
Total: ~15-20 hours

WEEK 11-12: PHASE 5
├─ Launchers (6-8 hrs)
├─ LLM scripts (4-6 hrs)
├─ Optional scripts (2-3 hrs)
├─ E2E testing (4-6 hrs)
└─ Documentation (2-3 hrs)
Total: ~20-25 hours

─────────────────────────
GRAND TOTAL: ~155-210 hours (10-12 weeks)
FAST-TRACK:  ~60-75 hours (4-5 weeks for core only)
```

---

## Critical Path Dependencies

```
START: Phase 1
  ↓
github.sh + python.sh → easyreforge_installer.sh
  ↓
Phase 1 complete → START Phase 2
  ↓
link_helper.sh → reforge.sh (critical, 50+ hours)
  ├─→ reforge_extension.sh
  ├─→ reforge_link.sh
  └─→ Config scripts
  ↓
Phase 2 complete → START Phase 3 OR 2b (parallel)
  ├─ Phase 3: Download helpers
  │   ├─ common.sh (others depend)
  │   ├─ civitai_download.sh
  │   ├─ huggingface_download.sh
  │   └─ ... (other helpers)
  │   ↓
  │   Phase 3 complete → Phase 4
  │   ├─ Generate 165 scripts
  │   ├─ Convert 20 meta-scripts
  │   └─ Convert 2 manual scripts
  │   ↓
  │   Phase 4 complete → END
  │
  └─ Phase 2b: Model linking (independent)
     ├─ link_input/output templates
     ├─ Replicate to 7 categories
     └─ Test symlinks
     ↓
     Phase 2b complete → Phase 5

Phase 5: Launchers + E2E testing → COMPLETE
```

---

## Success Criteria

### Phase 1
- [ ] easyreforge_installer.sh works via `bash` on Ubuntu
- [ ] `bash easyreforge_installer.sh` clones repos and calls setup.sh
- [ ] All scripts pass shellcheck validation

### Phase 2
- [ ] `bash setup.sh` completes without errors
- [ ] reforge.sh installs PyTorch correctly (GPU or CPU)
- [ ] 13 extensions cloned at correct commits
- [ ] Symlinks created and functional
- [ ] `bash reforge_noptions.sh` launches WebUI
- [ ] WebUI reachable at http://localhost:7860

### Phase 3
- [ ] All 7 download helpers created and tested
- [ ] Metadata CSV extracted from 176 .bat files
- [ ] Common.sh can handle error cases

### Phase 4
- [ ] 165+ scripts generated automatically
- [ ] All scripts pass shellcheck
- [ ] DRY_RUN=1 mode works for all scripts
- [ ] Meta-scripts call all children correctly

### Phase 2b
- [ ] Symlinks created in all 7 categories
- [ ] WebUI can access models through symlinks
- [ ] Relative paths work from any CWD

### Phase 5
- [ ] 8 launcher variants work
- [ ] 8 LLM scripts functional
- [ ] End-to-end test on fresh Ubuntu VM passes
- [ ] All 237 scripts have .sh equivalents
- [ ] Tested on Ubuntu 18.04, 20.04, 22.04

---

## Files to Reference

All planning documents are in `/home/ytsubame/src/EasyReforge-Ubuntu/docs/`:

- **01_analysis_overview.md** - Phase 0 analysis overview
- **01_analysis_detailed.md** - Phase 0 flow diagrams and detailed analysis
- **02_planning_phases.md** - This file: Phase summaries and script inventory
- **03_implementation_common_patterns.md** - Step-by-step implementation
- **04_reference_conversion_table.md** - Command conversion table
- **.claude/CLAUDE.md** - Project control center

---

## Key Statistics

| Metric | Count |
|--------|-------|
| Total batch files to convert | 237 |
| Phase 1 scripts | 5 |
| Phase 2 scripts | 9 |
| Phase 3 helper libraries | 7 |
| Phase 4 model scripts | 165+ |
| Phase 4 meta-scripts | 20 |
| Phase 2b linking scripts | 14 |
| Phase 5 launchers | 24+ |
| Total lines in original easyreforge installer | 160 |
| Estimated full implementation time | 155-210 hours |
| Estimated fast-track time (core only) | 60-75 hours |
| Phases running in parallel | 2b + others |

---

**Last Updated**: 2025-12-04
**Status**: Ready for Phase 1 implementation
**Next Step**: Begin Phase 1 with easyreforge_installer.sh conversion
**Reference**: See [docs/03_implementation_common_patterns.md](03_implementation_common_patterns.md) for step-by-step guide
