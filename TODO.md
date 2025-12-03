# EasyReforge Ubuntu Migration - Implementation Plan

**Status**: Planning Phase
**Last Updated**: 2025-12-03
**Total Scope**: 237 batch files → shell scripts conversion

# Status Legend
- [ ] Not started
- [-] In progress
- [x] Completed

---

## Executive Summary

This document outlines the complete plan for migrating EasyReforge from **Windows-only** to **Ubuntu-only**. The project requires converting 237 batch files (.bat) to shell scripts (.sh) while maintaining identical functionality.

**Key Facts**:
- **Repository Size**: 63MB
- **Total Batch Files**: 237
- **Current Shell Scripts**: 0
- **Estimated Effort**: 10-12 weeks (comprehensive)
- **Priority**: High-priority core scripts can be done in 4-5 weeks

---

## Project Structure Overview

```
EasyReforge-Ubuntu/
├── EasyReforge/                    # Main installation & setup (23 .bat files)
│   ├── Reforge/                    # reForge variant (PRIMARY FOCUS)
│   │   ├── Reforge.bat             → reforge.sh
│   │   ├── ReforgeExtension.bat    → reforge_extension.sh
│   │   ├── ReforgeConfig.bat       → reforge_config.sh
│   │   ├── ReforgeLink.bat         → reforge_link.sh
│   │   ├── ReforgeUiConfig.bat     → reforge_ui_config.sh
│   │   └── src/
│   │       ├── requirements.txt    (NO CONVERSION - portable)
│   │       ├── reforge_update_config.py    (NO CONVERSION - portable Python)
│   │       ├── reforge_update_ui-config.py (NO CONVERSION - portable Python)
│   │       ├── styles.csv          (NO CONVERSION - data file)
│   │       └── stable-diffusion-webui-reForge/ (Git submodule)
│   ├── A1111/                      # Automatic1111 variant (lower priority)
│   └── Forge/                      # Forge variant (lower priority)
├── EasyReforge/
│   ├── EasyReforgeInstaller.bat    → easyreforge_installer.sh
│   ├── Setup.bat                   → setup.sh
│   └── Update.bat                  → update.sh
├── Download/                       # Model downloads (176 .bat files)
│   ├── Stable-diffusion/           # 48 .bat files
│   ├── Lora/                       # 36 .bat files
│   ├── ControlNet/                 # 27 .bat files
│   ├── ESRGAN/                     # 7 .bat files
│   ├── wildcards/                  # 9 .bat files
│   ├── adetailer/, VAE/            # Others
│   ├── All/                        # 13 meta-scripts
│   └── src/                        # 2 composition scripts
├── Model/                          # Model linking scripts (14 .bat files)
│   ├── Stable-diffusion/           # LinkInput.bat, LinkOutput.bat
│   ├── Lora/, ControlNet/, VAE/    # ...
│   ├── ESRGAN/, adetailer/
│   └── wildcards/
├── Llm/                            # LLM inference scripts (8 .bat files)
├── Sample/                         # Demo scripts (1 .bat file)
├── Root-level launchers            # 15 .bat files (Reforge.bat, GenImageViewer.bat, etc.)
└── .claude/
    └── CLAUDE.md                   (Project guidelines - READ FIRST)
```

---

## Part 1: CORE INFRASTRUCTURE CONVERSION (9 files)

### Execution Priority: PHASE 1 & 2 (4-5 weeks)

These files form the foundation that all other components depend on.

#### Phase 1: Foundation Scripts (No Dependencies)

**1. easyreforge_installer.sh** ⭐ START HERE
- **Location**: `EasyReforge/easyreforge_installer.sh`
- **Purpose**: First-time installation - clones repos, validates environment
- **Conversions Needed**:
  - Remove Windows PowerShell path validation
  - Remove VC Runtime checks (Windows-specific)
  - Replace `chcp 65001` with locale settings
  - Convert registry modification to skip (Long Paths not relevant on Linux)
  - Remove Portable Git logic, use system git via apt-get
- **System Dependencies**: git, curl, bash, UTF-8 locale
- **Key Logic**: Clone EasyTools, initialize EasyReforge, call setup.sh
- **Estimated Time**: 4-6 hours

**2. update.sh**
- **Location**: `Update.bat` → `update.sh`
- **Purpose**: Update infrastructure and run setup
- **Conversions Needed**:
  - Remove `chcp 65001`
  - Update git path handling for Ubuntu
  - Adapt EasyTools Git initialization
- **System Dependencies**: git
- **Key Logic**: git fetch/reset both EasyTools and EasyReforge, call setup.sh
- **Estimated Time**: 2-3 hours

#### Phase 2: Core Environment Setup (Depends on Phase 1)

**3. reforge.sh (Reforge/Reforge.sh)** ⭐ CRITICAL
- **Location**: `EasyReforge/Reforge/reforge.sh`
- **Purpose**: Setup reForge WebUI environment - clone repo, install PyTorch, packages
- **Conversions Needed**:
  - CURL path: `C:\Windows\System32\curl.exe` → `curl`
  - Paths: `%~dp0` → bash script directory expansion
  - Virtual environment activation: `venv\Scripts\activate.bat` → `source venv/bin/activate`
  - TRITON_CACHE: Windows path → `$HOME/.triton/cache`
  - TORCH_INDUCTOR_TEMP: Windows path → `$HOME/.cache/torch/inductor_$(whoami)`
  - SageAttention wheel: Download Linux x86_64 version (not win_amd64)
  - llama-cpp-python wheel: Download Linux manylinux version
  - File operations: `xcopy` → `cp -r`, `rmdir /S /Q` → `rm -rf`
  - pushd/popd → subshells or cd
- **System Dependencies**: git, curl, python3.10+, pip3, CUDA toolkit, cuDNN
- **Key Logic**: Clone reForge repo, setup venv, install PyTorch+CUDA, install wheels, install requirements.txt, copy files
- **Critical Dependencies**:
  - GitHub_CloneOrPull.sh (MUST CREATE FIRST)
  - Python_Activate.sh (MUST CREATE FIRST)
- **Challenges**:
  - SageAttention may need custom Linux build
  - llama-cpp-python may need compilation
  - PyTorch CUDA index URLs must be correct for architecture
- **Estimated Time**: 12-16 hours (includes wheel validation)

**4. reforge_extension.sh**
- **Location**: `EasyReforge/Reforge/reforge_extension.sh`
- **Purpose**: Clone/update reForge extensions (13 GitHub repos)
- **Conversions Needed**:
  - Replace pushd/popd with subshells
  - Create extensions-backup: `mkdir` → `mkdir -p`
  - Move: `move /Y` → `mv -f`
  - Remove: `rmdir /S /Q` → `rm -rf`
  - Path separators: `\` → `/`
- **System Dependencies**: git
- **Key Logic**: Clone 13 extensions at specific commits, copy config files, move unsupported extensions to backup
- **Critical Dependencies**:
  - GitHub_CloneOrPull.sh (MUST CREATE FIRST)
- **Estimated Time**: 6-8 hours

**5. reforge_config.sh**
- **Location**: `EasyReforge/Reforge/reforge_config.sh`
- **Purpose**: Activate venv and run Python config migration script
- **Conversions Needed**:
  - venv activation: `call venv\Scripts\activate.bat` → `source venv/bin/activate`
  - Python call stays same: `python src/reforge_update_config.py`
- **System Dependencies**: Python 3.10+
- **Key Logic**: CD to WebUI, activate venv, run migration script
- **Estimated Time**: 1-2 hours

**6. reforge_ui_config.sh**
- **Location**: `EasyReforge/Reforge/reforge_ui_config.sh`
- **Purpose**: Activate venv and run Python UI config migration script
- **Conversions Needed**: Same as reforge_config.sh
- **Key Logic**: CD to WebUI, activate venv, run UI migration script
- **Estimated Time**: 1-2 hours

**7. reforge_link.sh**
- **Location**: `EasyReforge/Reforge/reforge_link.sh`
- **Purpose**: Create symbolic links for model directories
- **Conversions Needed**:
  - Junction/MKLINK → Linux `ln -s` (symlinks)
  - Create output directories structure
  - Handle existing symlinks (remove and recreate)
  - Create timestamp backups for non-link items
- **System Dependencies**: Standard Unix tools (ln, mkdir, cp, mv)
- **Key Logic**: Create symlinks for all 7 model categories, wildcard dir, output folders, OutputReforge symlink
- **Critical Dependencies**:
  - link_helper.sh (MUST CREATE FIRST)
- **Estimated Time**: 6-8 hours

**8. setup.sh**
- **Location**: `EasyReforge/setup.sh`
- **Purpose**: Main orchestration - calls Reforge setup, extensions, links
- **Conversions Needed**:
  - Remove VC Runtime download (Windows-only)
  - Remove VC Runtime checks
  - Remove Windows-specific path logic
- **System Dependencies**: All dependencies from called scripts
- **Key Logic**: Call reforge.sh → reforge_extension.sh → reforge_link.sh → conditional downloads
- **Critical Dependencies**:
  - reforge.sh, reforge_extension.sh, reforge_link.sh (must be complete first)
- **Estimated Time**: 2-3 hours

**9. reforge.sh (root launcher)**
- **Location**: `Reforge.bat` → `reforge.sh`
- **Purpose**: Root-level launcher that calls Reforge_NoOptions equivalent
- **Conversions Needed**:
  - Simple wrapper script
  - Pass through command-line arguments
- **Key Logic**: Source/call reforge_noptions.sh with arguments
- **Estimated Time**: 1-2 hours

### Helper Scripts Required for Core Infrastructure

**A. GitHub_CloneOrPull.sh** (REQUIRED for reforge.sh, reforge_extension.sh)
- **Location**: `EasyReforge/src/lib/github.sh` or similar
- **Parameters**: OWNER, REPO, BRANCH, COMMIT_HASH
- **Logic**: Clone from GitHub or update existing repo to specific commit
- **Estimated Time**: 3-4 hours

**B. Python_Activate.sh** (REQUIRED for reforge.sh)
- **Location**: `EasyReforge/src/lib/python.sh` or similar
- **Logic**: Create Python venv if needed, activate it
- **Estimated Time**: 1-2 hours

**C. link_helper.sh** (REQUIRED for reforge_link.sh)
- **Location**: `EasyReforge/Reforge/src/link_helper.sh`
- **Functions**:
  - check_source_path: Validate source directory exists and readable
  - check_dest_directory: Validate destination is writable
  - handle_existing_target: Remove existing symlink or backup non-link
  - create_symlink: Create symlink with error handling
  - get_timestamp: For backup naming
  - prompt_for_path: Interactive path input with validation
  - prompt_for_name: Get short name with optional override
- **Estimated Time**: 4-6 hours

---

## Part 2: DOWNLOAD SCRIPTS CONVERSION (176 files)

### Execution Priority: PHASE 3 & 4 (5-7 weeks)

The 176 download scripts are highly repetitive and template-based, making batch automation feasible.

#### Phase 3: Foundation & Helper Scripts (1-2 weeks)

**Core Strategy**: Create 6 helper script libraries, then generate 165+ scripts from metadata.

**Required Helpers** (in `/Download/lib/`):

1. **common.sh**
   - Purpose: Shared functions, error handling, logging
   - Functions: error handling, path validation, UTF-8 checks
   - Estimated Time: 4-6 hours

2. **civitai_download.sh**
   - Purpose: Civitai API implementation (66 scripts depend on this)
   - API: `civitai_download <model_dir> <filename> <model_id> <version_id>`
   - Logic: Construct URL, validate, download with curl
   - Estimated Time: 6-8 hours

3. **huggingface_download.sh**
   - Purpose: HuggingFace Models API (59 scripts depend on this)
   - API: `huggingface_download <model_dir> <filename> <repo_id> [optional_file]`
   - Logic: Use HF API or direct URL, handle optional file renaming
   - Estimated Time: 6-8 hours

4. **civitai_download_unzip.sh**
   - Purpose: Download Civitai zip and extract (21 scripts depend on this)
   - API: `civitai_download_unzip <model_dir> <model_id> <version_id>`
   - Logic: Download, extract, cleanup
   - Estimated Time: 4-5 hours

5. **huggingface_hub_download.sh**
   - Purpose: Alternative HF Hub API (4 scripts depend on this)
   - Logic: HF CLI or huggingface-hub library integration
   - Estimated Time: 3-4 hours

6. **aria_download.sh**
   - Purpose: Direct URL downloads (4 scripts depend on this)
   - API: `aria_download <model_dir> <filename> <url>`
   - Logic: Direct download with aria2 or curl
   - Estimated Time: 2-3 hours

7. **recursive_call.sh**
   - Purpose: Replace RecursiveBatCall.bat - execute all .sh in directory
   - Logic: Find and execute all *.sh files recursively with error handling
   - Estimated Time**: 3-4 hours

**Metadata Extraction Tool** (Python):
- Purpose: Parse all 176 .bat files → CSV → generate .sh
- Deliverable: CSV mapping with script type, parameters, helper type
- Estimated Time: 8-12 hours

**Phase 3 Estimated Total**: 2-3 weeks

#### Phase 4: Script Generation & Testing (2-3 weeks)

**Task 1: Model Download Scripts** (165 scripts - AUTOMATED)
- Extract metadata from all 176 batch files
- Generate .sh scripts from templates:
  - Civitai model downloads: 66 scripts
  - HuggingFace model downloads: 59 scripts
  - Civitai zip downloads: 21 scripts
  - HF Hub downloads: 4 scripts
  - Direct URL downloads: 4 scripts
  - Other variants: 11 scripts
- Validation: shellcheck all generated scripts
- Estimated Time**: 1-2 weeks

**Task 2: Meta-Scripts & Orchestrators** (20 scripts - SEMI-AUTOMATED)
- Convert 12 `All/*.bat` meta-scripts (directory recursion pattern)
- Convert 8 root-level variant selectors (Epsilon/V-Pred)
- Pattern: Use recursive_call.sh for directory traversal
- Estimated Time: 1-2 weeks

**Task 3: Manual Conversions** (2 scripts - MANUAL)
- Convert `Download/src/NoobAiCommon_Minimum.bat` (~30 chained calls)
- Convert `Download/src/NoobAiCommon_Standard.bat` (~7 calls)
- Estimated Time: 2-3 days

**Task 4: Validation & Testing**
- Dry-run testing (DRY_RUN=1 mode - no actual downloads)
- Integration testing (meta-scripts call children correctly)
- Error handling validation
- Estimated Time: 1-2 weeks

---

## Part 3: MODEL LINKING SCRIPTS CONVERSION (14 files)

### Execution Priority: PHASE 2 or PHASE 4 (2-3 weeks)

Convert symlink/junction creation from Windows to Linux native symlinks.

#### Phase Overview

**Architecture**: 7 categories × 2 script types (LinkInput + LinkOutput)

**Key Difference**:
- Windows: `MKLINK /J` (NTFS junctions)
- Linux: `ln -s` (POSIX symlinks)

**Helper Library Required** (CREATED IN CORE INFRASTRUCTURE PHASE):

**link_helper.sh** (3-4 hours):
- check_source_path()
- check_dest_directory()
- handle_existing_target()
- create_symlink()
- get_timestamp()
- prompt_for_path()
- prompt_for_name()

**Conversion Tasks** (1-2 weeks):

1. **Create Link Templates** (2-3 days)
   - Create `Model/Stable-diffusion/link_input.sh` template
   - Create `Model/Stable-diffusion/link_output.sh` template
   - Test both thoroughly

2. **Replicate to All Categories** (3-4 days)
   - Copy templates to 6 remaining categories
   - Adjust paths for each category
   - Test each category

3. **Testing** (3-4 days)
   - Unit tests for link_helper.sh
   - Integration tests for LinkInput/LinkOutput
   - Test reforge_link.sh orchestration
   - Symlink validation and directory traversal

**Estimated Total**: 2-3 weeks (can overlap with other phases)

---

## Part 4: OPTIONAL LAUNCHERS & UTILITIES (24 files)

### Execution Priority: PHASE 5 (2-3 weeks) - OPTIONAL

These are secondary launchers not required for core functionality.

#### Optional Launcher Scripts

1. **Reforge_Fast.sh** - Optimized launch
2. **Reforge_NoOptions.sh** - Minimal launch
3. **Reforge_ArgSample_DarkTheme.sh** - CLI arg template
4. **Reforge_RTX50x0_PipTorch260Cu128.sh** - GPU-specific
5. **gen_image_viewer.sh** - Image viewer extension
6. **infinite_image_browsing.sh** - Infinite browsing extension
7. **lama_cleaner.sh** - Image inpainting tool
8. **sd_image_diet.sh** - Image optimization
9. **mosaic.sh** - Mosaic utility
10. A1111 variants (lower priority)
11. Forge variants (lower priority)
12. LLM inference scripts (8 files)

**Estimated Time**: 1-3 hours each (repetitive patterns)

---

## Critical System Dependencies Checklist

### Required on Ubuntu Before Running Scripts

```bash
# Core tools (install first)
sudo apt-get update
sudo apt-get install -y \
    git \
    curl \
    python3 \
    python3-venv \
    python3-pip \
    build-essential \
    python3-dev \
    xdg-utils

# For NVIDIA GPU support
sudo apt-get install -y nvidia-utils
# Manual CUDA 12.8 & cuDNN installation required

# Optional but recommended
sudo apt-get install -y shellcheck   # Script validation
```

---

## Phase-by-Phase Execution Timeline

### Recommended Execution Order

```
WEEK 1-2: PHASE 1 - Foundation
  ├─ Helper Scripts:
  │   ├─ GitHub_CloneOrPull.sh (3-4 hrs)
  │   └─ Python_Activate.sh (1-2 hrs)
  ├─ Core Scripts:
  │   ├─ easyreforge_installer.sh (4-6 hrs) ⭐ START
  │   ├─ update.sh (2-3 hrs)
  │   └─ setup.sh (2-3 hrs)

WEEK 3-4: PHASE 2 - Core Environment
  ├─ Helper Scripts:
  │   ├─ link_helper.sh (4-6 hrs)
  │   └─ [Continue with next phase in parallel]
  ├─ Core Scripts:
  │   ├─ reforge.sh (12-16 hrs) ⭐ CRITICAL
  │   ├─ reforge_extension.sh (6-8 hrs)
  │   ├─ reforge_config.sh (1-2 hrs)
  │   ├─ reforge_ui_config.sh (1-2 hrs)
  │   ├─ reforge_link.sh (6-8 hrs)
  │   └─ reforge.sh root launcher (1-2 hrs)

WEEK 5-6: PHASE 3 - Download Foundation
  ├─ Helper Libraries:
  │   ├─ common.sh (4-6 hrs)
  │   ├─ civitai_download.sh (6-8 hrs)
  │   ├─ huggingface_download.sh (6-8 hrs)
  │   ├─ civitai_download_unzip.sh (4-5 hrs)
  │   ├─ huggingface_hub_download.sh (3-4 hrs)
  │   ├─ aria_download.sh (2-3 hrs)
  │   └─ recursive_call.sh (3-4 hrs)
  └─ Metadata Extraction Tool (8-12 hrs)

WEEK 7-8: PHASE 4 - Model Script Generation
  ├─ Generate 165+ model download scripts (automated) (3-5 days)
  ├─ Convert 20 meta/orchestrator scripts (1-2 days)
  ├─ Convert 2 composition scripts manually (1-2 days)
  └─ Validation & testing (3-5 days)

WEEK 9-10: PHASE 2b - Model Linking (PARALLEL with Phase 4)
  ├─ Create link_input.sh template (2-3 days)
  ├─ Create link_output.sh template (2-3 days)
  ├─ Replicate to 6 categories (3-4 days)
  └─ Testing (3-4 days)

WEEK 11-12: PHASE 5 - Optional Launchers & QA
  ├─ Convert 8 Reforge launcher variants (2-3 days)
  ├─ Convert optional extension launchers (1-2 days)
  ├─ Convert LLM inference scripts (1-2 days)
  ├─ End-to-end testing with fresh Ubuntu VM (2-3 days)
  ├─ Documentation updates (1-2 days)
  └─ Final validation & cleanup (1-2 days)
```

**Total**: 10-12 weeks for complete migration

**Fast-Track**: 4-5 weeks for core infrastructure only (Part 1)

---

## Testing Strategy

### Phase 1-2 Testing (Core Infrastructure)

1. **Unit Tests**
   - Test GitHub_CloneOrPull.sh with mock repos
   - Test link_helper.sh functions
   - Test Python venv creation and activation

2. **Integration Tests**
   - Run easyreforge_installer.sh from scratch
   - Verify directory structure created correctly
   - Verify git repos cloned at correct commits
   - Run setup.sh and verify:
     - Python venv created
     - PyTorch installed
     - Extensions cloned
     - Symlinks created

3. **Functional Tests**
   - Run reforge_noptions.sh
   - Verify WebUI launches at http://localhost:7860
   - Load a model and generate a test image
   - Check output directory structure

### Phase 3-4 Testing (Download Scripts)

1. **Dry-Run Testing**
   ```bash
   DRY_RUN=1 bash Download/Stable-diffusion/NoobE/AniKawa.sh
   # Should print: [DRY-RUN] Would download: ...
   ```

2. **Integration Testing**
   - Meta-scripts call all child scripts
   - Variant selectors work correctly (Minimum → Standard → All)
   - Error propagation up call chain

3. **Validation**
   - shellcheck all 176 generated scripts
   - Compare generated vs. original (manual for sample)

### Phase 2b Testing (Model Linking)

1. **Link Creation Tests**
   - Test LinkInput creation with external folder
   - Test LinkOutput creation with destination
   - Verify symlinks are correct type (`test -L`)

2. **Directory Traversal Tests**
   - Verify WebUI can read models through symlinks
   - Python can traverse linked directories
   - Files accessible as if directly present

3. **Symlink Validation**
   - Symlink points to correct location
   - Symlink target is readable
   - Relative paths work from any CWD

---

## Known Issues & Mitigations

### Issue 1: SageAttention Wheels
**Problem**: Windows-specific .whl file (win_amd64)
**Solution**: Download Linux x86_64 version or custom build
**Status**: Requires research on availability
**Mitigation**: Build from source if wheels unavailable

### Issue 2: llama-cpp-python Compilation
**Problem**: May require compilation on Ubuntu
**Solution**: Pre-built manylinux wheel should work
**Status**: Verify with test installation
**Mitigation**: If fails, use fallback to pure Python version

### Issue 3: Interactive Input in Non-TTY
**Problem**: `read -p` fails in non-interactive shells
**Solution**: Detect TTY status and provide sensible defaults
**Status**: Plan error handling for LinkInput/LinkOutput
**Mitigation**: Support piped input like `echo "path" | link_input.sh`

### Issue 4: CUDA Version Compatibility
**Problem**: PyTorch wheel must match system CUDA version
**Solution**: Detect CUDA version and download correct wheel
**Status**: Implement nvidia-smi detection
**Mitigation**: Fallback to CPU-only version if CUDA unavailable

### Issue 5: Model Download API Rate Limiting
**Problem**: Civitai/HF may rate-limit downloads
**Solution**: Add configurable delays between downloads
**Status**: Implement in common.sh
**Mitigation**: Document rate limits and caching strategy

---

## Configuration Files (NO CONVERSION NEEDED)

These files are portable and work on Ubuntu without modification:

- `EasyReforge/Reforge/src/requirements.txt` - Python package list (portable)
- `EasyReforge/Reforge/src/styles.csv` - UI presets (data format)
- `EasyReforge/Reforge/src/resolutions.txt` - Resolution presets
- `EasyReforge/Reforge/src/1girl.txt`, `play.txt`, `aspect_ratios.txt` - Wildcard data
- `EasyReforge/Reforge/src/GenImageViewer.json` - Extension config
- All model description/metadata files

**Note**: Path references in JSON/config files may need updating from Windows to Unix paths.

---

## Python Scripts (NO CONVERSION NEEDED)

These Python scripts are already portable and work on Ubuntu unchanged:

- `reforge_update_config.py` - Config migration (uses stdlib + json)
- `reforge_update_ui-config.py` - UI config migration (uses stdlib + json)
- `forge_update_config.py` - Forge variant
- `forge_update_ui-config.py` - Forge UI config variant

They will be called by shell scripts unchanged.

---

## Implementation Priorities & Trade-offs

### Must-Have (Core Infrastructure)
- [ ] easyreforge_installer.sh
- [ ] setup.sh
- [ ] reforge.sh (Reforge/Reforge.sh)
- [ ] reforge_extension.sh
- [ ] reforge_link.sh
- [ ] reforge_noptions.sh

**Effort**: 4-5 weeks

**Delivers**: Fully functional reForge installation on Ubuntu

### Should-Have (Download Automation)
- [ ] All Download helpers (6 scripts)
- [ ] Model download scripts (154-165 scripts)
- [ ] Meta-scripts (12 scripts)

**Effort**: 5-7 weeks additional

**Delivers**: Full automation parity with Windows version

### Nice-to-Have (Optional Launchers)
- [ ] Launcher variants
- [ ] LLM inference scripts
- [ ] Optional utilities

**Effort**: 2-3 weeks additional

**Delivers**: 100% feature parity

---

## Success Criteria

- [ ] All 237 batch files have .sh equivalents
- [ ] Core infrastructure works on Ubuntu 18.04+ without modification
- [ ] WebUI launches and can generate images
- [ ] Model downloads work correctly
- [ ] Symlinks created and functional
- [ ] All scripts pass shellcheck validation
- [ ] All scripts have proper error handling (exit codes)
- [ ] Documentation updated (CLAUDE.md, README, etc.)
- [ ] Tested on multiple Ubuntu versions
- [ ] No breaking changes to user workflows

---

## Files to Review Before Starting

1. **Read FIRST**: `/home/ytsubame/src/EasyReforge-Ubuntu/.claude/CLAUDE.md`
   - Contains detailed context about project structure, architecture, and conventions

2. **Reference**: Original Windows batch files for exact logic
   - `EasyReforge/EasyReforgeInstaller.bat`
   - `EasyReforge/Setup.bat`
   - `EasyReforge/Reforge/Reforge.bat`
   - Others as needed during implementation

3. **Configuration**: Key files to preserve
   - `requirements.txt` - Must install all 197 Python packages correctly on Ubuntu
   - `styles.csv` - Must remain compatible with reForge WebUI
   - Python migration scripts - Must execute correctly from shell scripts

---

## Next Steps

1. **Start**: Implement `easyreforge_installer.sh` (Part 1, Phase 1)
   - This is the entry point and validates the conversion approach

2. **Continue**: Complete core infrastructure Phase 1-2 (4-5 weeks)
   - Get full installation working on Ubuntu

3. **Parallelize**: Start Phase 3 download helpers while finishing Phase 2

4. **Scale**: Generate 165+ download scripts using automated approach

5. **Validate**: Comprehensive testing across Ubuntu versions

---

## Change Log

**2025-12-03** - Initial planning document created
- Analyzed 237 batch files across 8 major categories
- Identified 3 specialist agents to create detailed plans
- Consolidated findings into comprehensive TODO.md
- Prioritized core infrastructure (9 files) vs. downloads (176 files) vs. linking (14 files)
- Estimated 10-12 week full migration, 4-5 weeks for core only
