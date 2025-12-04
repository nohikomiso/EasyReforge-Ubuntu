# CLAUDE.md - EasyReforge Ubuntu Migration

**Status**: Implementation Planning Complete
**Last Updated**: 2025-12-03
**Mode**: Ubuntu-only Project (Windows support removed)

This file provides comprehensive guidance for implementing the EasyReforge Ubuntu migration. It serves as the control center for all development work related to converting 237 Windows batch scripts to Ubuntu shell scripts.

---

## Quick Start for Developers

**New to this project?** Read in this order:
1. **[docs/00_phase0_analysis/README.md](../docs/00_phase0_analysis/README.md)** - Phase 0: Understand the original Windows installer flow
2. This file (CLAUDE.md) - Project overview and architecture
3. [docs/01_planning/phase_breakdown.md](../docs/01_planning/phase_breakdown.md) - Complete implementation plan (10-12 weeks estimated)
4. [docs/02_implementation/common_patterns.md](../docs/02_implementation/common_patterns.md) - Step-by-step instructions with detailed cautions
5. [docs/03_reference/batch_to_shell_conversion.md](../docs/03_reference/batch_to_shell_conversion.md) - Batch-to-shell conversion cookbook

**Ready to code?**
- Start with Phase 0 analysis: [docs/00_phase0_analysis/README.md](../docs/00_phase0_analysis/README.md)
- Then begin Phase 1: [docs/02_implementation/phase_1/overview.md](../docs/02_implementation/phase_1/overview.md)
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
- **PyTorch** 2.7.1 with CUDA 12.8 support (Python 3.10.x required)
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
- **Python** 3.10.x with pip3 (tested on 3.10.6+, strictly 3.10, no 3.11)
- **NVIDIA GPU** with CUDA 12.8 support (RTX 3060+ recommended)
- **20GB+** free disk space
- **CUDA Toolkit** and **cuDNN** (bundled in PyTorch, no separate installation needed)

### Python/CUDA Version Compatibility Matrix

| Component | Windows Original | Ubuntu Target | Verified |
|-----------|------------------|---------------|----------|
| **Python** | 3.10.6 (portable) | 3.10.x (system) | ✅ Ubuntu 24.04 |
| **CUDA Toolkit** | Not needed (bundled) | Not needed (bundled in PyTorch) | ✅ |
| **NVIDIA Driver** | 525.60.13+ | 525.60.13+ | Required for GPU |
| **PyTorch** | 2.7.1+cu128 | 2.7.1+cu128 | ✅ |
| **TorchVision** | 0.22.1+cu128 | 0.22.1+cu128 | ✅ |
| **TorchAudio** | 2.7.1+cu128 | 2.7.1+cu128 | ✅ |
| **SageAttention** | 2.2.0 (win_amd64) | 2.2.0 (linux_x86_64) | ✅ User-built |
| **llama-cpp-python** | 0.3.4 (wheel) | 0.3.4 (build with CUDA) | Needs testing |
| **Wheel ABI** | cp310-cp310-win_amd64 | cp310-cp310-linux_x86_64 | ✅ |

**Python Installation** (Ubuntu 24.04):
```bash
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.10 python3.10-venv python3.10-dev
python3.10 --version  # Verify 3.10.x
```

**Note**: No CUDA Toolkit installation needed. PyTorch 2.7.1+cu128 includes all necessary CUDA 12.8 libraries and cuDNN.

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

## Phase 0: Analysis & Design (Completed)

**Status**: ✅ Complete
**Deliverables**: Comprehensive analysis of EasyReforgeInstaller.bat
**Location**: [docs/00_phase0_analysis/](../docs/00_phase0_analysis/)

### Purpose
Phase 0 precedes all implementation. It analyzes how the original Windows `EasyReforgeInstaller.bat` works to design an equivalent Ubuntu `easyreforge_installer.sh` that can be invoked via `curl` directly.

### Key Deliverables
1. **ANALYSIS_SUMMARY.md** - Executive overview
   - Original 10-step installation flow
   - System dependencies and prerequisites
   - Exit codes and error handling

2. **easyreforge_analysis.md** - Technical deep-dive
   - Detailed flow for each installation step
   - All called scripts and their purposes
   - Complete environment variable mapping
   - Ubuntu migration considerations

3. **flow_diagram.txt** - Visual flowcharts
   - ASCII execution timeline
   - Script call hierarchy
   - Conditional execution paths

4. **line_by_line_analysis.txt** - Ultra-detailed reference
   - All 160 lines annotated with explanations
   - Variable expansions and effects
   - Edge cases and quirks

### Key Findings

**Original EasyReforgeInstaller.bat - 10 Steps**:
1. Environment setup (UTF-8, variables)
2. Validate prerequisites (where.exe, PowerShell, curl)
3. Validate installation path (no spaces/special chars)
4. Check for conflicting WebUI installations
5. Ensure Git availability (portable Git fallback)
6. Clone/initialize EasyTools repository
7. Clone/initialize EasyReforge repository
8. Call Setup.bat → Reforge.bat, ReforgeExtension.bat, etc.
9. Optional model downloads
10. Cleanup & self-delete + registry setup

**Ubuntu Equivalent Strategy**:
- Keep the identical 10-step flow
- Replace `.bat` calls with `.sh` calls
- Replace `where.exe` with `command -v`
- Replace PowerShell regex with bash regex
- Skip registry operations
- Support `curl | bash` execution

### Design Principles
- **Flow Preservation**: Keep original 10-step sequence unchanged
- **Robustness**: Maintain extensive error checking
- **User-Friendly**: Preserve bilingual interface
- **One-Command**: Enable `curl | bash` bootstrap
- **Reproducibility**: Version pinning and exact commits

### Next Phase
Phase 1 implementation will create `easyreforge_installer.sh` based on Phase 0 analysis.

**See**: [docs/00_phase0_analysis/README.md](../docs/00_phase0_analysis/README.md) for complete analysis

---

## Implementation Phases Overview

### Phase 1: Foundation Scripts & Bootstrap (Weeks 1-2, 4-6 hours)
**Goal**: Create one-command bootstrap installer based on Phase 0 analysis
**Based on**: [Phase 0 Analysis](../docs/00_phase0_analysis/README.md) - EasyReforgeInstaller.bat 10-step flow

**Deliverables**:
- **easyreforge_installer.sh** - Ubuntu bootstrap (implements Phase 0 10-step flow)
  - Prerequisites validation (git, curl, bash)
  - Path validation (alphanumeric only, no spaces)
  - Git repository initialization (EasyTools, EasyReforge)
  - Orchestrates downstream scripts
  - Supports `curl | bash` execution
- **Helper libraries**:
  - github.sh (git clone/pull logic)
  - python.sh (venv setup)
- **setup.sh** - Main orchestrator calling reforge.sh, extensions, linking
- **update.sh** - Update infrastructure

**Flow** (from Phase 0 analysis):
1. Environment setup (UTF-8, variables)
2. Prerequisites validation → `command -v` (not where.exe)
3. Path validation → bash regex (not PowerShell)
4. Conflict detection (existing WebUI)
5. Git availability → system only (not portable fallback)
6. Clone EasyTools
7. Clone EasyReforge
8. Call setup.sh
9. Optional model downloads
10. Cleanup & exit

**Success Criteria**:
- easyreforge_installer.sh runs via `curl | bash` without errors
- All Phase 0 10-step flow implemented
- setup.sh can be called from installer
- All scripts pass shellcheck validation
- Cross-platform on Ubuntu 18.04+

**Reference**: [docs/02_implementation/phase_1/overview.md](../docs/02_implementation/phase_1/overview.md) and [Phase 0 Documents](../docs/00_phase0_analysis/)

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

### ⚠️ CRITICAL: Design-First Approach (NOT Simple Syntax Conversion)

**RULE**: ❌ **DO NOT** simply convert `.bat` syntax to `.sh` syntax. Instead:

1. **Analyze** the batch file to understand **what it's trying to do** (purpose/intent)
2. **Design** the optimal Ubuntu/Linux implementation based on that understanding
3. **Implement** using shell-scripting best practices with `shell-scripting` Skill
4. **Leverage** Linux native commands and apt-installed tools (not Windows workarounds)

**Bad Example (❌ Forbidden)**:
```bash
# DO NOT do this - simple syntax replacement
# Windows: call other.bat
bash other.sh  # ← Wrong: just replacing syntax

# Windows: xcopy /sqy src dst
cp -r src/* dst/  # ← Wrong: doesn't understand intent
```

**Good Example (✅ Correct)**:
```bash
# Understand the purpose: "Copy directory recursively with overwrite"
# Linux implementation: Use rsync for efficiency
rsync -av --delete src/ dst/  # ← Right: optimized for Linux

# OR understand: "Install Python venv if needed"
# Linux implementation: Use apt-get first
if ! command -v python3 &> /dev/null; then
    apt install -y python3 python3-venv
fi
```

### Analysis-to-Design Process

For each batch file you need to convert:

1. **Read the original `.bat` file completely**
   - Understand every step and variable
   - Identify the overall goal (not individual commands)

2. **Reference EasyEnv/EasyTools patterns** (see `/home/ytsubame/src/_research_reference/`)
   - These Windows libraries often contain the logic to understand
   - Example: `EasyEnv/Git/GitPull.bat` shows "URL validation → clone or pull decision"

3. **Design the Ubuntu equivalent**
   - What Linux tools are available? (git, curl, aria2c, unzip, etc.)
   - Can apt install provide this? (avoid reinventing wheels)
   - What's the most efficient bash approach?

4. **Implement with shell-scripting Skill**
   - Use `Skill shell-scripting` when implementing complex scripts
   - Ensures Linux best practices and safety

5. **Reference the conversion table as needed** (not as primary source)
   - Use [docs/04_reference_conversion_table.md](../docs/04_reference_conversion_table.md) for specific syntax
   - But always prioritize purpose-based design over syntax mapping

### Quick Batch-to-Shell Reference

Use this table as a **syntax lookup**, not as implementation guidance. See [docs/04_reference_conversion_table.md](../docs/04_reference_conversion_table.md) for complete reference.

| Windows Batch | Ubuntu Shell | Purpose | Example |
|--------------|-------------|---------|---------|
| `set VAR=value` | `VAR=value` | Variable assignment | `MODEL_DIR="/path/to/models"` |
| `%VAR%` | `$VAR` | Variable expansion | `echo "$VAR"` |
| `%~dp0` | `$(dirname "${BASH_SOURCE[0]}")` | Script directory | `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` |
| `call script.bat` | `bash script.sh` | Call another script | `bash "${SCRIPT_DIR}/setup.sh"` |
| `pushd dir & popd` | `(cd dir; ...)` | Temporary directory change | `(cd models; ls)` |
| `rmdir /s /q dir` | `rm -rf dir` | Recursive delete | `rm -rf cache/` |
| `xcopy /sqy src dst` | `cp -r src/* dst/` or `rsync -av` | Directory copy (choose based on purpose!) | See design note above |
| `findstr pattern file` | `grep pattern file` | Text search | `grep "error" log.txt` |
| `if exist path` | `if [ -d "path" ]` | Path exists check | `if [ -d "models" ]; then...` |
| `@echo off` | (no equivalent) | Silence output | Bash is quiet by default |

**How to use this table**:
- This is a **quick lookup for basic syntax**
- It is **NOT** a substitute for design-first approach
- Always understand the purpose first, then choose the right tool

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

**Reference**: [docs/03_implementation_common_patterns.md](../docs/03_implementation_common_patterns.md)

### 🛠️ shell-scripting Skill Usage (MANDATORY)

**When to use the `shell-scripting` Skill**:

When implementing complex shell scripts (especially Phase 1-3 helper libraries), you **MUST** use the Claude Code `shell-scripting` Skill to ensure:
- Shell best practices and safety
- Proper error handling and edge cases
- Cross-platform compatibility (bash 4.0+ on Ubuntu)
- Efficient Linux native command usage

**Example workflow**:
1. Analyze the batch file purpose
2. Design the Ubuntu/Linux approach
3. Use `Skill shell-scripting` to implement the `.sh` file
4. Review output for Linux best practices
5. Test with `shellcheck` and manual testing

This ensures all scripts follow professional shell scripting standards, not just quick syntax translations.

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

### Phase 0: Analysis & Design (Completed ✅)
- [x] EasyReforgeInstaller.bat analyzed (160 lines)
- [x] 10-step flow documented
- [x] All called scripts identified (20+ downstream)
- [x] Environment variables catalogued
- [x] Error handling mapped (20+ exit paths)
- [x] Ubuntu migration considerations documented
- [x] ANALYSIS_SUMMARY.md created
- [x] easyreforge_analysis.md created
- [x] flow_diagram.txt created
- [x] line_by_line_analysis.txt created
- [x] Phase 0 README.md created
- [x] CLAUDE.md updated with Phase 0 section
- [x] Phase 0 documents committed to ubuntu-migration

### Phase 1: Foundation Scripts & Bootstrap (Weeks 1-2, 4-6 hours)
- [ ] Study Phase 0 analysis: [docs/00_phase0_analysis/README.md](../docs/00_phase0_analysis/README.md)
- [ ] github.sh created (clone/pull logic from Phase 0 analysis)
- [ ] python.sh created (venv setup)
- [ ] **easyreforge_installer.sh** created (implements 10-step Phase 0 flow)
  - [ ] Step 1: Environment setup (UTF-8, variables)
  - [ ] Step 2: Prerequisites validation (git, curl, bash)
  - [ ] Step 3: Path validation (alphanumeric, no spaces)
  - [ ] Step 4: Conflict detection (existing WebUI)
  - [ ] Step 5: Git availability check
  - [ ] Step 6: Clone EasyTools repository
  - [ ] Step 7: Clone EasyReforge repository
  - [ ] Step 8: Call setup.sh orchestrator
  - [ ] Step 9: Optional model downloads
  - [ ] Step 10: Cleanup & exit
  - [ ] Passes shellcheck validation
  - [ ] Works via `curl | bash` execution
- [ ] update.sh created, passes shellcheck
- [ ] setup.sh created, passes shellcheck
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

**Current Phase**: Phase 0 Complete ✅, Ready for Phase 1 Implementation
**Total Scripts**: 237 batch files identified and analyzed
**Phase 0 Status**:
  - ✅ EasyReforgeInstaller.bat completely analyzed (160 lines, 10-step flow)
  - ✅ Phase 0 analysis documents created (5 files, 1,300+ lines)
  - ✅ CLAUDE.md updated with Phase 0 section and Phase 1 alignment
  - ✅ Phase 0 documents committed to ubuntu-migration branch
**Helper Scripts Required**: 9 (GitHub, Python, link_helper, 7 download helpers)
**Estimated Timeline**: 10-12 weeks (full), 4-5 weeks (core infrastructure)
**Implementation Order**:
  - Phase 0: ✅ Complete (analysis)
  - Phase 1: → Next (bootstrap installer from Phase 0 analysis)
  - Phases 2-5: Sequential with parallel phases possible from Week 9+

**Next Step**: Begin Phase 1 with easyreforge_installer.sh based on Phase 0 10-step flow
- **Reference**: [Phase 0 Analysis Documents](../docs/00_phase0_analysis/README.md)
- **Implementation Guide**: [Phase 1 Overview](../docs/02_implementation/phase_1/overview.md)

---

## File Modification Log

| Date | Author | Change |
|------|--------|--------|
| 2025-12-03 | Implementation | Phase 0 Analysis Complete - Added Phase 0 section, updated Quick Start, aligned Phase 1 with Phase 0 findings |
| 2025-12-03 | Implementation | Created Phase 0 analysis documents (5 files, 1,300+ lines) in docs/00_phase0_analysis/ |
| 2025-12-03 | Implementation | Updated Implementation Checklist with Phase 0 completion and Phase 1 10-step breakdown |
| 2025-12-03 | Implementation | Updated Project Status to reflect Phase 0 completion, ready for Phase 1 |
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
