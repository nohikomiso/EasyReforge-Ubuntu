# Phase 2 Implementation Guide - Core Environment Setup

**Status**: Template for Phase 2 implementation work
**Phase**: 2 of 5 (Weeks 3-4)
**Complexity**: HIGH (Highest - reforge.sh is CRITICAL)
**Estimated Time**: 60-75 hours

---

## IMPORTANT: Design-First Approach (Required Reading)

**DO NOT simply translate batch syntax to shell syntax.**

Phase 2 contains the most critical scripts. Each must be designed from scratch:

### Mandatory Process for Each Script

1. **Analyze the original .bat file's PURPOSE** (not just its commands)
2. **Study EasyEnv/EasyTools patterns**: `/home/ytsubame/src/_research_reference/ANALYSIS_REPORT.md`
3. **Design the Ubuntu-optimal solution** using native Linux tools
4. **Invoke `Skill shell-scripting`** when implementing
5. **Use `04_reference_conversion_table.md` only for syntax lookup** (not as primary guide)

### Reference Documents
- `.claude/CLAUDE.md` - Script Conversion Guidelines section (MANDATORY)
- `docs/03_implementation_common_patterns.md` - Batch File Analysis Process
- `/home/ytsubame/src/_research_reference/ANALYSIS_REPORT.md` - Windows library analysis

---

## Overview

Phase 2 creates the fully functional reForge environment. It depends on Phase 1 completion.

### Phase 2 Goals
1. PyTorch and dependencies installed with correct platform wheel
2. 13 extensions cloned at specific commits
3. Symlinks created for model directories
4. Configuration migrated from Windows
5. WebUI launches and works

### Critical Script: reforge.sh
This script is the most complex. Plan 40-50 hours for it.

**Key Challenges**:
- Platform-specific PyTorch wheels
- SageAttention compatibility
- Environment variable setup for CUDA/compilation
- Virtual environment activation

---

## Implementation Checklist

### Before Starting Phase 2
- [ ] Phase 1 (easyreforge_installer.sh) complete and tested
- [ ] github.sh helper working
- [ ] uv.sh helper working
- [ ] Read `.claude/CLAUDE.md` - Caution sections
- [ ] Read `docs/03_implementation_common_patterns.md` - Phase 2 section
- [ ] Have access to original Phase 2 batch files for reference

### Phase 2 Tasks (In Order)

#### Task 1: link_helper.sh
- **File**: `EasyReforge/Reforge/src/link_helper.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 4-6 hours
- **Functions needed**:
  - check_source_path()
  - check_dest_directory()
  - handle_existing_target()
  - create_symlink()
  - get_timestamp()
  - prompt_for_path() (interactive)
  - prompt_for_name() (interactive)
- **Tests**: [ ] Passed all symlink creation tests
- **Validation**: [ ] Passed shellcheck

#### Task 2: reforge.sh (CRITICAL)
- **File**: `EasyReforge/Reforge/reforge.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 40-50 hours (most complex)
- **Pre-implementation analysis** (REQUIRED):
  - [ ] Read original Reforge.bat completely
  - [ ] Study EasyEnv Python/venv handling: `_research_reference/ANALYSIS_REPORT.md`
  - [ ] Document the PURPOSE of each section (not just commands)
  - [ ] Design Ubuntu-native approach (apt packages, not portable binaries)
  - [ ] Invoke `Skill shell-scripting` for implementation
- **Key sections**:
  - [ ] Environment setup (CUDA, Triton cache, etc.)
  - [ ] Python venv creation
  - [ ] PyTorch installation (platform-specific wheels)
  - [ ] SageAttention wheel handling
  - [ ] llama-cpp-python wheel handling
  - [ ] requirements.txt installation
  - [ ] WebUI initialization
- **Critical cautions applied**: [ ] All 6 cautions addressed
- **Validation**: [ ] Passed shellcheck

#### Task 3: reforge_extension.sh
- **File**: `EasyReforge/Reforge/reforge_extension.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 6-8 hours
- **Key elements**:
  - [ ] 13 extensions cloned at correct commits
  - [ ] Extension backup directory created
  - [ ] Unsupported extensions moved to backup
  - [ ] Config files copied
- **Validation**: [ ] Passed shellcheck

#### Task 4: reforge_link.sh
- **File**: `EasyReforge/Reforge/reforge_link.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 6-8 hours
- **Symlinks to create**:
  - [ ] 7 model categories (Stable-diffusion, Lora, ControlNet, VAE, ESRGAN, adetailer, wildcards)
  - [ ] Output directories
  - [ ] OutputReforge directory
- **Validation**: [ ] Passed shellcheck, symlinks verified

#### Task 5: reforge_config.sh
- **File**: `EasyReforge/Reforge/reforge_config.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 1-2 hours
- **Key logic**:
  - [ ] CD to WebUI directory
  - [ ] Activate venv
  - [ ] Call reforge_update_config.py
- **Validation**: [ ] Passed shellcheck

#### Task 6: reforge_ui_config.sh
- **File**: `EasyReforge/Reforge/reforge_ui_config.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 1-2 hours
- **Key logic**:
  - [ ] CD to WebUI directory
  - [ ] Activate venv
  - [ ] Call reforge_update_ui-config.py
- **Validation**: [ ] Passed shellcheck

#### Task 7: Root launcher reforge.sh
- **File**: `EasyReforge/reforge.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 1-2 hours
- **Key logic**:
  - [ ] Simple wrapper calling Reforge_NoOptions.sh
  - [ ] Pass through command-line arguments
- **Validation**: [ ] Passed shellcheck

### Integration Testing
- [ ] Phase 2 setup scripts run sequentially without errors
- [ ] uv venv created correctly
- [ ] PyTorch installed (verify with `uv run python -c "import torch"`)
- [ ] All 13 extensions cloned
- [ ] Symlinks created and valid
- [ ] Config migration complete
- [ ] WebUI launches: `bash reforge_noptions.sh`
- [ ] WebUI reachable at http://localhost:7860

### Final Verification
- [ ] All Phase 2 scripts pass shellcheck
- [ ] No Windows-specific code remaining
- [ ] All absolute paths converted to relative or $-syntax
- [ ] UTF-8 locale set in all scripts
- [ ] Error handling with `set -euo pipefail` + trap
- [ ] Ready for Phase 3 start

---

## Critical Implementation Notes

### reforge.sh Platform-Specific Cautions (40+ hours work)

**Caution 1: PyTorch Wheels - CRITICAL Python 3.10 Requirement**
- Windows: `torch-2.7.1+cu128-cp310-cp310-win_amd64.whl`
- Ubuntu: `torch-2.7.1+cu128-cp310-cp310-manylinux_2_17_x86_64.whl`
- **CRITICAL**: Must use Python 3.10.x (not 3.11 or 3.12) - all wheels are tagged cp310
- **Action**: Detect CUDA version, download correct Linux manylinux wheel for Python 3.10

**Caution 2: SageAttention**
- Windows wheel (win_amd64) not available on Linux
- **Action**: Try Linux manylinux wheel, fallback to source build

**Caution 3: llama-cpp-python**
- May require compilation on Linux
- **Action**: Attempt pre-built wheel, fallback to source build

**Caution 4: Environment Variables**
- Set TRITON_CACHE, TORCH_INDUCTOR_TEMP **BEFORE** uv pip install
- **Action**: Export before installing packages

**Caution 5: Virtual Environment**
- Windows: `venv\Scripts\activate.bat` に依存した実行
- Ubuntu: `uv run` による仮想環境内コマンドの直接実行
- **Action**: `source` を使った面倒な有効化作業を廃止し、Python実行時は常に `uv run` を使用する

**Caution 6: File Operations**
- Windows: `xcopy`, `rmdir /S /Q`
- Ubuntu: `cp -r`, `rm -rf`
- **Action**: Use rsync for large copies, rm -rf with caution

---

## uv を利用した Python 3.10 自動取得 (Required for All Wheel Tags)

**CRITICAL**: Stable Diffusion系やPyTorchのwheelエコシステムは `cp310` タグを前提としています。Python 3.11 や 3.12 は使用できません。

### Python 3.10 環境の構築 (uvを利用)

旧来の `python3 -m venv` や システムPPA (deadsnakes) の追加は不要です。`uv` を用いることで、OS環境を汚さずにプロジェクト専用の Python 3.10 を自動取得・配置できます。

```bash
# uv による Python 3.10 仮想環境の構築
uv venv .venv --python 3.10

# 稼働確認（有効化手順なしで直接環境内コマンドを実行）
uv run python --version  # Python 3.10.x が表示される
```

### Why strictly Python 3.10.x?

- **Original Windows version**: Uses Python 3.10.6 (portable)
- **All wheel tags**: Every critical package uses `cp310` tags (CPython 3.10)
- **Python 3.11+ incompatible**: cp311/cp312 wheels are incompatible with cp310 requirements
- **Wheel examples**:
  - `torch-2.7.1+cu128-cp310-cp310-manylinux_2_17_x86_64.whl` ✓ Compatible
  - `torch-2.7.1+cu128-cp311-cp311-manylinux_2_17_x86_64.whl` ✗ Incompatible

---

## Specialized Wheel Installation Instructions

### SageAttention 2.2.0 Linux Wheel Installation

Unlike Windows, SageAttention must be installed from a pre-built Linux wheel:

```bash
# The wheel is located at: wheels/sageattention-2.2.0-cp310-cp310-linux_x86_64.whl
# Ensure the wheels directory exists relative to the script
uv pip install wheels/sageattention-2.2.0-cp310-cp310-linux_x86_64.whl

# Verify installation
python -c "from sageattention import sageattn; print('✓ SageAttention loaded')"
```

**Failure handling**: If the wheel is not found or installation fails:
- Log the error but continue (non-critical functionality)
- The WebUI will work without SageAttention optimization
- Attempt to install again in a future update if the wheel becomes available

**Wheel location**: Must be bundled with the project at:
- `EasyReforge/Reforge/wheels/sageattention-2.2.0-cp310-cp310-linux_x86_64.whl`

### llama-cpp-python 0.3.4 with CUDA Support

Unlike Windows wheels, llama-cpp-python on Linux must be built from source with CUDA support enabled:

```bash
# Build llama-cpp-python with CUDA support
# This enables GPU acceleration for local LLM inference
CMAKE_ARGS="-DLLAMA_CUBLAS=on" uv pip install llama-cpp-python==0.3.4

# Verify CUDA support is enabled
python -c "from llama_cpp import Llama; print('✓ llama-cpp-python with CUDA loaded')"
```

**Build requirements**:
- cmake (typically installed with build-essential)
- NVIDIA CUDA toolkit (included with PyTorch installation)
- Requires 10-15 minutes for source build on first install

**Failure handling**: If source build fails:
1. Attempt CPU-only fallback: `uv pip install llama-cpp-python==0.3.4`
2. If still failing, skip LLM features (non-critical)
3. Log the error and continue WebUI setup

**Performance note**: CUDA-enabled llama-cpp-python is significantly faster for local LLM inference. Worth the build time.

---

## Reference Materials

- **Original files**: Check `EasyReforge/Reforge/*.bat` for exact logic
- **Common patterns**: See `docs/03_implementation_common_patterns.md` - Phase 2 section
- **Batch conversions**: Reference `docs/04_reference_conversion_table.md`
- **CLAUDE.md**: For cautions and conventions

---

## Progress Tracking

**Week 3 (Start of Phase 2)**:
- [ ] link_helper.sh created (day 1-2)
- [ ] reforge.sh part 1 (day 3-5) - environment setup

**Week 4**:
- [ ] reforge.sh part 2 (days 6-8) - PyTorch + wheels
- [ ] reforge_extension.sh (day 9-10)
- [ ] reforge_link.sh (day 11-12)

**Week 4 continued**:
- [ ] Config scripts (day 13)
- [ ] Root launcher (day 13-14)
- [ ] Integration testing (day 15+)

---

## Success Criteria

Phase 2 is complete when:
- [ ] All Phase 2 scripts pass shellcheck validation
- [ ] `bash setup.sh` completes without errors
- [ ] WebUI launches: `bash reforge_noptions.sh`
- [ ] WebUI accessible at http://localhost:7860
- [ ] Model loading works in WebUI
- [ ] Image generation test passes
- [ ] No Windows-specific code remaining
- [ ] All dependencies correctly installed

---

## Known Issues to Watch For

1. **CUDA version mismatch**: Always verify nvidia-smi output
2. **Virtual environment activation**: Test with `python -c "import sys; print(sys.prefix)"`
3. **Symlink creation**: Verify with `test -L` commands
4. **Wheel download failures**: Have source build fallbacks ready

---

**Last Updated**: 2025-12-04
**Status**: Template ready for implementation
**Next Phase**: Phase 3 (Download Helpers)
