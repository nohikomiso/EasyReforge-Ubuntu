# CLAUDE.md - EasyReforge Ubuntu Migration

**Status**: Implementation Planning Complete
**Last Updated**: 2025-12-03
**Mode**: Ubuntu-only Project (Windows support removed)

This file provides comprehensive guidance for implementing the EasyReforge Ubuntu migration. It serves as the control center for all development work related to converting 237 Windows batch scripts to Ubuntu shell scripts.

---

## Quick Start for Developers

**New to this project?** Read in this order:
1. This file (CLAUDE.md) - Project overview and architecture
2. [docs/01_planning/phase_breakdown.md](../docs/01_planning/phase_breakdown.md) - Complete implementation plan (10-12 weeks estimated)
3. [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md) - Step-by-step instructions with detailed cautions
4. [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md) - Batch-to-shell conversion cookbook

**Ready to code?**
- Start with [docs/02_implementation/phase_1/overview.md](../docs/02_implementation/phase_1/overview.md)
- Reference [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md) for specific command conversions
- Follow the [Implementation Checklist](#implementation-checklist) below

---

## Project Context

**EasyReforge** is a turnkey installer and configuration manager for reForge (Stable Diffusion WebUI fork), transitioning from **Windows-only to Ubuntu-only**. The project uses shell scripts (.sh) for all automation, replacing 237 original Windows batch files (.bat).

### Key Facts
- **Repository Size**: 63MB
- **Total Scripts to Convert**: 237 batch files
- **Estimated Full Effort**: 10-12 weeks
- **Fast-Track (Core Only)**: 4-5 weeks
- **Primary Focus**: reForge WebUI setup and model management
- **Target Platform**: Ubuntu 18.04+ (tested on modern versions)

---

## Repository Structure

```
EasyReforge-Ubuntu/
├── EasyReforge/                         # Main installation (23 .bat → .sh)
│   ├── easyreforge_installer.sh         # First-time setup [PHASE 1]
│   ├── setup.sh                         # Main orchestrator [PHASE 1]
│   ├── update.sh                        # Update infrastructure [PHASE 1]
│   │
│   ├── Reforge/                         # reForge variant (PRIMARY FOCUS)
│   │   ├── reforge.sh                   # Core environment setup [PHASE 2 - CRITICAL]
│   │   ├── reforge_extension.sh         # Install extensions [PHASE 2]
│   │   ├── reforge_link.sh              # Create symlinks [PHASE 2]
│   │   ├── reforge_config.sh            # Config migration [PHASE 2]
│   │   ├── reforge_ui_config.sh         # UI config migration [PHASE 2]
│   │   ├── src/
│   │   │   ├── requirements.txt         # 198 Python packages (NO CONVERSION)
│   │   │   ├── reforge_update_config.py # Config migration (NO CONVERSION - portable Python)
│   │   │   ├── reforge_update_ui-config.py # UI config (NO CONVERSION - portable Python)
│   │   │   ├── styles.csv               # UI presets (NO CONVERSION - data file)
│   │   │   ├── link_helper.sh           # Symlink utilities [PHASE 2 HELPER]
│   │   │   ├── lib/                     # Helper libraries
│   │   │   │   ├── github.sh            # Git clone/pull [PHASE 1 HELPER]
│   │   │   │   └── python.sh            # Python venv setup [PHASE 1 HELPER]
│   │   │   └── stable-diffusion-webui-reForge/ # Git submodule
│   │   │
│   │   └── Reforge_NoOptions.sh         # Main launcher [PHASE 2]
│   │
│   ├── A1111/                           # Automatic1111 variant (lower priority)
│   └── Forge/                           # Forge variant (lower priority)
│
├── Download/                            # Model downloads (176 .bat → .sh) [PHASE 3-4]
│   ├── lib/                             # Helper libraries [PHASE 3]
│   │   ├── common.sh                    # Shared utilities
│   │   ├── civitai_download.sh          # Civitai API (66 scripts depend)
│   │   ├── huggingface_download.sh      # HuggingFace Models (59 scripts)
│   │   ├── civitai_download_unzip.sh    # Zip downloads (21 scripts)
│   │   ├── huggingface_hub_download.sh  # HF Hub alternative (4 scripts)
│   │   ├── aria_download.sh             # Direct downloads (4 scripts)
│   │   └── recursive_call.sh            # Directory recursion
│   │
│   ├── Stable-diffusion/                # 48 model scripts [PHASE 4 - AUTOMATED]
│   ├── Lora/                            # 36 model scripts [PHASE 4 - AUTOMATED]
│   ├── ControlNet/                      # 27 model scripts [PHASE 4 - AUTOMATED]
│   ├── ESRGAN/, VAE/, adetailer/, wildcards/  # Others
│   └── All/                             # 13 meta-scripts [PHASE 4]
│
├── Model/                               # Symlink scripts (14 .bat → .sh) [PHASE 2b]
│   ├── Stable-diffusion/
│   │   ├── link_input.sh                # Link external source
│   │   └── link_output.sh               # Link output destination
│   ├── Lora/, ControlNet/, VAE/, ESRGAN/, adetailer/, wildcards/
│
├── Llm/                                 # LLM inference (8 .bat → .sh) [PHASE 5]
├── Sample/                              # Demo scripts (1 .bat → .sh) [PHASE 5]
├── Root launchers/                      # 15 launchers [PHASE 5]
│
├── TODO.md                              # Complete implementation plan
├── IMPLEMENTATION_GUIDE.md              # Step-by-step guide with cautions
├── SCRIPT_CONVERSION_REFERENCE.md       # Batch-to-shell reference table
└── .claude/
    └── CLAUDE.md                        # This file (project guidelines)
```

---

## Core Technologies & Dependencies

### ML Stack
- **PyTorch** 2.7.1 with CUDA 12.8 support
- **reForge** (git submodule at `stable-diffusion-webui-reForge/`)
- **FastAPI/Uvicorn** + **Gradio 3.41.2** for WebUI
- **198 Python packages** (see `requirements.txt`)

### Key Python Libraries
- diffusers 0.28.2, transformers 4.48.1 (Hugging Face)
- accelerate 0.21.0, safetensors 0.5.2 (optimization)
- sageattention 2.2.0 (optimized attention)
- opencv, pillow, albumentations (image processing)
- llama-cpp-python (local LLM inference)
- deepdanbooru, ultralytics, mediapipe (detection/tagging)
- dynamicprompts (wildcard support)

### System Requirements
- **OS**: Ubuntu 18.04+ (recommended: 20.04 or later)
- **Git**, **curl**, **bash** 4.0+
- **Python** 3.10+ with pip3
- **NVIDIA GPU** with CUDA 12.8 support (RTX 3060+ recommended)
- **20GB+** free disk space
- **CUDA Toolkit** and **cuDNN** (installed separately)

### Pre-Installation Checklist
```bash
# Test required tools
git --version           # Should be 2.25+
bash --version          # Should be 4.0+
python3 --version       # Should be 3.10+
nvidia-smi              # NVIDIA GPU detection (optional but recommended)
shellcheck --version    # For validation (optional)

# Recommended: Install dependencies
sudo apt-get update
sudo apt-get install -y git curl python3 python3-venv python3-pip \
    build-essential python3-dev xdg-utils shellcheck
```

---

## Implementation Phases Overview

### Phase 1: Foundation Scripts (Weeks 1-2, 4-6 hours)
**Goal**: Get core infrastructure working
- Create 2 helper libraries (GitHub_CloneOrPull, Python_Activate)
- Convert 3 main scripts (easyreforge_installer, update, setup)
- All dependencies in place, ready for Phase 2

**Success Criteria**:
- easyreforge_installer.sh runs without errors
- setup.sh can be called from installer
- All scripts pass shellcheck validation

**See**: [docs/02_implementation/phase_1/overview.md](../docs/02_implementation/phase_1/overview.md)

### Phase 2: Core Environment Setup (Weeks 3-4, 30-40 hours)
**Goal**: Fully functional reForge installation
- **CRITICAL**: reforge.sh (PyTorch, dependencies, wheels)
- reforge_extension.sh (13 GitHub extensions)
- reforge_link.sh (symlink creation)
- Config migration scripts
- Root launcher

**Success Criteria**:
- Python venv created and activated
- PyTorch installed with CUDA support
- Extensions cloned at correct commits
- Symlinks created and functional
- WebUI launches: `bash reforge.sh`

**See**: [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md)

### Phase 3: Download Helpers (Weeks 5-6, 25-35 hours)
**Goal**: Foundation for model download automation
- Create 7 helper libraries in `Download/lib/`
- Parse 176 batch files to metadata CSV
- Setup for automated script generation

**Success Criteria**:
- All 7 helpers created and tested
- Metadata CSV complete and validated
- Download helpers work with test data

**See**: [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md)

### Phase 4: Model Script Generation (Weeks 7-8, 30-40 hours)
**Goal**: Automated download scripts for 165+ models
- Generate scripts from metadata (automated)
- Convert 20 meta-scripts (semi-automated)
- Validate all scripts with shellcheck

**Success Criteria**:
- 165+ scripts generated successfully
- Dry-run testing passes (`DRY_RUN=1`)
- All scripts pass shellcheck
- Meta-scripts call children correctly

**See**: [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md)

### Phase 2b: Model Linking (Weeks 9-10, 15-20 hours, Parallel)
**Goal**: Symlink templates for user model directories
- Create link_input.sh template (external sources)
- Create link_output.sh template (output destinations)
- Replicate to 7 model categories

**Success Criteria**:
- Symlinks created correctly
- WebUI can read models through symlinks
- Relative paths work from any CWD

**See**: [docs/01_planning/phase_breakdown.md](../docs/01_planning/phase_breakdown.md)

### Phase 5: Optional Launchers & QA (Weeks 11-12, 15-25 hours)
**Goal**: Feature parity with Windows version
- Convert 8 reforge launcher variants
- Convert 8 LLM inference scripts
- Convert optional extension launchers
- End-to-end testing on fresh Ubuntu VM

**Success Criteria**:
- All 237 scripts have .sh equivalents
- Scripts tested on multiple Ubuntu versions
- Documentation complete
- Ready for public release

**See**: [docs/01_planning/phase_breakdown.md](../docs/01_planning/phase_breakdown.md)

---

## Key Architecture Patterns

### Build System Architecture
**Original (Windows)**: Batch scripts with sequential error checking
**Ubuntu Equivalent**: Shell scripts (.sh) with bash/zsh compatibility

Pattern: Modular scripts where each performs one concern (clone repo, install deps, create links) and calls others in sequence with exit code verification.

### Configuration Management
- **Versioned migrations**: `reforge_update_config.py` handles backward-compatible config updates
- **CSV-driven presets**: `styles.csv` contains UI state and generation parameters (no code changes needed to add presets)
- **Git submodules**: reForge WebUI cloned into `src/stable-diffusion-webui-reForge/`

### Model Organization
- Models stored in `Model/` with subdirectories mirroring `Download/` structure
- Symbolic links created by `*_link.sh` scripts (Linux native symlinks replace Windows junctions)
- Resource sharing enabled through `LinkInput/LinkOutput` scripts

### Extension Management
- 13 reForge extensions specified with hardcoded GitHub repos and commits
- Each extension cloned to exact commit hash for reproducibility
- Unsupported extensions backed up with timestamps, not deleted

---

## Critical Implementation Cautions

### Caution 1: PyTorch Platform-Specific Wheels
**Issue**: PyTorch wheels vary by platform (Windows win_amd64 → Linux manylinux2014_x86_64)

**Solution**:
- Detect NVIDIA GPU with `nvidia-smi`
- Download correct CUDA version wheel (cu128 for 12.8)
- Fallback to CPU-only if GPU not detected
- Handle wheel download failures with source build fallback

**Reference**: [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md)

### Caution 2: SageAttention Wheel Availability
**Issue**: Windows wheel (win_amd64) not available on Linux

**Solution**:
- Download Linux manylinux version if available
- Fallback to source build if wheel unavailable
- Pre-build and test before rolling out

**Status**: Requires research on Linux wheel availability

### Caution 3: Virtual Environment Activation
**Issue**: Windows uses `venv\Scripts\activate.bat`, Linux uses `source venv/bin/activate`

**Solution**:
- Always use full paths: `source "${VENV_PATH}/bin/activate"`
- Test activation verification: `python3 -c "import sys; sys.exit(0 if 'venv' in sys.prefix else 1)"`

**Reference**: [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md)

### Caution 4: Symlink Semantics
**Issue**: Windows junctions (MKLINK /J) vs Linux symlinks (ln -s)
- Windows junctions: Directory-level, kernel-level transparency
- Linux symlinks: File-level, Python sees them as links

**Solution**:
- Use `ln -s` for directory symlinks
- Test with `test -L` to verify symlink creation
- Verify WebUI can traverse symlinks (may need Python traversal fixes)

**Reference**: [docs/02_implementation/phase_1/overview.md](../docs/02_implementation/phase_1/overview.md)

### Caution 5: Path Handling
**Issue**: Windows backslashes (`\`) vs Linux forward slashes (`/`)

**Solution**:
- Never hardcode Windows paths like `C:\path`
- Use `$HOME`, `$(pwd)`, script directory expansion
- Always use forward slashes in shell scripts

**Pattern**: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`

**Reference**: [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md)

### Caution 6: UTF-8 Encoding
**Issue**: Windows uses `chcp 65001` for UTF-8; required for Japanese UI

**Solution**:
- Add at start of every script: `export LC_ALL=C.UTF-8`
- Test with Japanese text in prompts
- Verify output displays correctly

**Pattern**: See [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md)

### Caution 7: Interactive Input Non-TTY Issues
**Issue**: `read -p` fails in non-interactive shells (pipes, cron, systemd)

**Solution**:
- Detect TTY: `[ -t 0 ]`
- Provide sensible defaults when non-interactive
- Support piped input: `echo "path" | link_input.sh`

**Reference**: [docs/03_reference/known_issues.md](../docs/03_reference/known_issues.md)

---

## Important Configuration Files

| File | Location | Purpose | Status |
|------|----------|---------|--------|
| `requirements.txt` | `EasyReforge/Reforge/src/` | Python package versions (pinned for reproducibility) | NO CONVERSION |
| `reforge_update_config.py` | `EasyReforge/Reforge/src/` | Version-based config migrations | NO CONVERSION - Portable Python |
| `reforge_update_ui-config.py` | `EasyReforge/Reforge/src/` | UI config migrations and layout state tracking | NO CONVERSION - Portable Python |
| `styles.csv` | `EasyReforge/Reforge/src/` | UI presets with generation parameters (~30+ presets) | NO CONVERSION - Data file |
| `GenImageViewer.json` | `EasyReforge/Reforge/src/` | Image viewer extension configuration | NO CONVERSION |

**Text Data Files** (in `EasyReforge/Reforge/src/`):
- `resolutions.txt` - Aspect ratio presets
- `1girl.txt`, `play.txt`, `aspect_ratios.txt` - Wildcard files

---

## Script Conversion Guidelines

### Quick Batch-to-Shell Reference

Use this table for 90% of conversions. See [SCRIPT_CONVERSION_REFERENCE.md](../SCRIPT_CONVERSION_REFERENCE.md) for complete reference.

| Windows Batch | Ubuntu Shell | Example |
|--------------|-------------|---------|
| `set VAR=value` | `VAR=value` | `MODEL_DIR="/path/to/models"` |
| `%VAR%` | `$VAR` | `echo "$VAR"` |
| `%~dp0` | `$(dirname "${BASH_SOURCE[0]}")` | `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` |
| `call script.bat` | `bash script.sh` | `bash "${SCRIPT_DIR}/setup.sh"` |
| `pushd dir & popd` | `(cd dir; ...)` | `(cd models; ls)` |
| `rmdir /s /q dir` | `rm -rf dir` | `rm -rf cache/` |
| `xcopy /sqy src dst` | `cp -r src/* dst/` | `cp -r webui/* deployment/` |
| `findstr pattern file` | `grep pattern file` | `grep "error" log.txt` |
| `if exist path` | `if [ -d "path" ]` | `if [ -d "models" ]; then...` |
| `@echo off` | (no equivalent) | Bash runs quietly by default |

**Complete Reference**: See [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md) for all conversions including loops, functions, git operations, error handling patterns, and gotchas.

### Script Structure Template

Every converted script should follow this structure:

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Get script directory (use for relative paths)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup environment
setup_environment() {
    export LC_ALL=C.UTF-8
    # ... other setup ...
}

# Main logic
main() {
    setup_environment
    # ... implementation ...
}

main "$@"
```

### Code Style Requirements

- **Shebang**: `#!/bin/bash` (not `#!/bin/sh`)
- **Error handling**: Use `set -euo pipefail`
- **Trap errors**: `trap 'echo "Error on line $LINENO"; exit 1' ERR`
- **Naming**: `lowercase_with_underscores` for functions and variables
- **Path handling**: Always quote variables: `"$VAR"`
- **Comments**: Only for non-obvious logic
- **Helper sourcing**: Include with full path: `source "${SCRIPT_DIR}/../lib/common.sh"`

**Reference**: [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md)

---

## Testing & Validation

### Before Committing Each Script

```bash
# Syntax check
shellcheck script.sh

# Test execution
bash script.sh

# Test with strict options
bash -o pipefail script.sh

# Dry-run mode (if applicable)
DRY_RUN=1 bash script.sh

# Error handling
bash script.sh 2>&1 | grep -i error
```

### Phase Testing

**Phase 1**: Verify easyreforge_installer.sh can run setup.sh
**Phase 2**: Verify WebUI launches: `bash reforge.sh && bash reforge_noptions.sh`
**Phase 3**: Verify download helpers parse metadata correctly
**Phase 4**: Verify generated scripts pass shellcheck and dry-run mode
**Phase 2b**: Verify symlinks created and traversable by Python
**Phase 5**: End-to-end test on fresh Ubuntu VM

**Full Testing Checklist**: [docs/03_reference/checklist.md](../docs/03_reference/checklist.md)

---

## Known Behaviors & Edge Cases

### 1. Style Backups
`Update.sh` overwrites `styles.csv` with default version
- Users should back up manual edits; backups created with timestamps
- Migration handled in `reforge_update_ui-config.py`

### 2. Config Migrations
If modifying config schema, add version handler to `reforge_update_config.py`
- Each version number maps to an `update_X_X_X()` function
- Ensure backward compatibility for existing users

### 3. VRAM Management
Some UI presets target RTX 3060 (12GB) specifically
- Lower VRAM optimizations in UI: `Never OOM Integrated`, `Low VRAM`
- Don't hardcode memory assumptions

### 4. V-Prediction vs Epsilon-Prediction
- **NoobE** = Epsilon (simpler, recommended for beginners)
- **NoobV** = V-Prediction (newer, requires `Advanced Model Sampling` toggle)
- Both fully supported; presets exist for both

### 5. Bilingual UI
Japanese + English localization included
- Controlled by `Settings` → `Bilingual Localization` dropdown
- Don't remove localization files; make it optional
- Always set UTF-8: `export LC_ALL=C.UTF-8`

### 6. Model Download Rate Limiting
Civitai/HuggingFace may rate-limit downloads
- Add configurable delays between downloads in `Download/lib/common.sh`
- Document rate limits and caching strategy
- Implement with environment variable: `DOWNLOAD_DELAY=5`

---

## When Modifying This Codebase

### Adding New Models/Resources
1. Create new `.sh` script in appropriate `Download/` subdirectory
2. Follow naming convention: `ModelName_vXX.sh`
3. Use template from Phase 4 automated generation
4. Update `Download/All/` meta-scripts if adding new category

### Updating Dependencies
- Edit `EasyReforge/Reforge/src/requirements.txt`
- Test with `pip install -r requirements.txt` on Ubuntu
- Document breaking changes in commit message

### Modifying UI Presets
- Edit `EasyReforge/Reforge/src/styles.csv`
- Each preset row: name, negative prompt, prompt, sampling method, CFG scale, etc.
- No code changes needed; new presets appear in UI automatically

### Updating Extensions
- Edit `reforge_extension.sh` (list of 13 repos and commits)
- Add repos in same format as existing entries
- Test by running the extension script and verifying UI

---

## Implementation Checklist

### Phase 1: Foundation (Weeks 1-2)
- [ ] GitHub_CloneOrPull.sh created, tested, documented
- [ ] Python_Activate.sh created, tested, documented
- [ ] easyreforge_installer.sh converted, passes shellcheck
- [ ] update.sh converted, passes shellcheck
- [ ] setup.sh converted, passes shellcheck
- [ ] Integration test: easyreforge_installer.sh → setup.sh succeeds
- [ ] All Phase 1 scripts committed and reviewed

### Phase 2: Core Environment (Weeks 3-4)
- [ ] link_helper.sh created with all 7 functions
- [ ] reforge.sh converted (most critical - 30-40 hours)
  - [ ] PyTorch detection and installation
  - [ ] Specialized wheel handling
  - [ ] requirements.txt installation
  - [ ] Environment variable setup
- [ ] reforge_extension.sh converted with 13 extensions
- [ ] reforge_link.sh converted with symlink creation
- [ ] reforge_config.sh and reforge_ui_config.sh converted
- [ ] Root reforge.sh launcher created
- [ ] Integration test: Full installation and WebUI launch
- [ ] All Phase 2 scripts pass shellcheck
- [ ] All Phase 2 scripts committed and reviewed

### Phase 3: Download Foundation (Weeks 5-6)
- [ ] 7 helper libraries created and tested:
  - [ ] common.sh
  - [ ] civitai_download.sh
  - [ ] huggingface_download.sh
  - [ ] civitai_download_unzip.sh
  - [ ] huggingface_hub_download.sh
  - [ ] aria_download.sh
  - [ ] recursive_call.sh
- [ ] Metadata extraction tool created
- [ ] CSV metadata generated from all 176 .bat files
- [ ] All helpers pass shellcheck

### Phase 4: Model Script Generation (Weeks 7-8)
- [ ] 165+ scripts generated from metadata (automated)
- [ ] shellcheck validation passes for all scripts
- [ ] 20 meta-scripts converted (semi-automated)
- [ ] 2 composition scripts converted (manual)
- [ ] Dry-run testing (`DRY_RUN=1`) passes
- [ ] Meta-scripts call children correctly
- [ ] All generated scripts committed

### Phase 2b: Model Linking (Weeks 9-10, Parallel)
- [ ] link_input.sh template created
- [ ] link_output.sh template created
- [ ] Templates replicated to 7 categories
- [ ] Symlinks created and functional
- [ ] WebUI can traverse symlinks
- [ ] All linking scripts committed

### Phase 5: Optional & QA (Weeks 11-12)
- [ ] 8 Reforge launcher variants converted
- [ ] 8 LLM inference scripts converted
- [ ] Optional extension launchers converted
- [ ] End-to-end testing on fresh Ubuntu VM
- [ ] Documentation complete and reviewed
- [ ] CLAUDE.md updated with final status
- [ ] Ready for release

---

## Success Criteria

The migration is complete when:
- [ ] All 237 batch files have corresponding .sh files
- [ ] Core infrastructure works on Ubuntu 18.04+ without modification
- [ ] WebUI launches and can generate images
- [ ] Model downloads work correctly
- [ ] Symlinks created and functional
- [ ] All scripts pass shellcheck validation
- [ ] All scripts have proper error handling (exit codes)
- [ ] Documentation updated
- [ ] Tested on multiple Ubuntu versions (18.04, 20.04, 22.04)
- [ ] No breaking changes to user workflows
- [ ] Japanese UI fully functional with UTF-8

---

## File Organization & Naming

### Script Naming Convention
- Use `lowercase_with_underscores.sh`
- Not `CamelCase.sh` or `kebab-case.sh`
- Examples:
  - ✅ `easyreforge_installer.sh`
  - ✅ `reforge_extension.sh`
  - ✅ `civitai_download.sh`
  - ❌ `EasyReforgeInstaller.sh` (too similar to original .bat)
  - ❌ `reforge-extension.sh` (inconsistent with project)

### Helper Library Locations
- Core helpers: `EasyReforge/src/lib/` (GitHub, Python)
- Download helpers: `Download/lib/` (civitai, huggingface, etc.)
- Reforge-specific: `EasyReforge/Reforge/src/` (link_helper)

### Directory Structure Preservation
Mirror the original batch file structure as much as possible for consistency:
```
Download/Stable-diffusion/NoobE/AniKawa.sh    (was AniKawa.bat)
Download/Lora/Char/Char_v123.sh               (was Char_v123.bat)
Model/Stable-diffusion/link_input.sh          (was LinkInput.bat)
```

---

## References & Links

### Official Projects
- **Original Project**: https://github.com/Zuntan03/EasyReforge
- **reForge**: https://github.com/Panchovix/stable-diffusion-webui-reForge
- **NoobAI Models**: https://civitai.com/models/833294
- **Troubleshooting Wiki**: https://github.com/Zuntan03/EasyReforge/wiki

### Development Tools
- **ShellCheck**: https://www.shellcheck.net/ (validate shell scripts)
- **Bash Manual**: https://www.gnu.org/software/bash/manual/
- **POSIX Shell**: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html

### Documentation
- **docs/01_planning/**: Complete implementation plan with timeline
- **docs/02_implementation/**: Step-by-step with detailed cautions
- **docs/03_reference/**: Batch-to-shell conversion cookbook and troubleshooting

---

## Quick Links to Detailed Documentation

Start here based on your role:

**I want to understand the full scope**
→ [docs/01_planning/phase_breakdown.md](../docs/01_planning/phase_breakdown.md) - Comprehensive plan with timeline

**I'm ready to start coding**
→ [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md) - Step-by-step with cautions

**I need to convert a specific script**
→ [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md) - Command-by-command reference

**I want to understand the architecture**
→ This file (CLAUDE.md) + [docs/00_quickstart/architecture.md](../docs/00_quickstart/architecture.md)

---

## Project Status

**Current Phase**: Planning Complete, Ready for Implementation
**Total Scripts**: 237 batch files identified and analyzed
**Helper Scripts Required**: 9 (GitHub, Python, link_helper, 7 download helpers)
**Estimated Timeline**: 10-12 weeks (full), 4-5 weeks (core infrastructure)
**Implementation Order**: Sequential with parallel phases possible from Week 9+

**Next Step**: Begin Phase 1 with easyreforge_installer.sh (see [docs/02_implementation/phase_1/overview.md](../docs/02_implementation/phase_1/overview.md))

---

## File Modification Log

| Date | Author | Change |
|------|--------|--------|
| 2025-12-03 | Planning Team | Complete rewrite to incorporate TODO.md, IMPLEMENTATION_GUIDE.md, and SCRIPT_CONVERSION_REFERENCE.md |
| 2025-12-03 | Planning Team | Added 5 implementation phases with detailed checklists |
| 2025-12-03 | Planning Team | Integrated critical cautions and references to detailed guides |

---

## Contact & Questions

For implementation questions:
1. Check [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md) first (detailed step-by-step)
2. Reference [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md) for specific conversions
3. Review [docs/01_planning/phase_breakdown.md](../docs/01_planning/phase_breakdown.md) for timeline and dependencies
4. Check original batch files for exact behavior to replicate

This CLAUDE.md serves as the control center. Always refer to the more detailed guides for specifics.

---

**Last Updated**: 2025-12-03 | **Status**: Ready for Implementation | **Phase**: 1 of 5
