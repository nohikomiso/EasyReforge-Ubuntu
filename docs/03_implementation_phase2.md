# Phase 2 Implementation Guide - Core Environment Setup

**Status**: Template for Phase 2 implementation work
**Phase**: 2 of 5 (Weeks 3-4)
**Complexity**: ⭐⭐⭐⭐⭐ (Highest - reforge.sh is CRITICAL)
**Estimated Time**: 60-75 hours

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
- [ ] python.sh helper working
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
- [ ] Python venv created correctly
- [ ] PyTorch installed (verify with `python -c "import torch"`)
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

**Caution 1: PyTorch Wheels**
- Windows: `torch-2.7.1+cu128-cp311-cp311-win_amd64.whl`
- Ubuntu: `torch-2.7.1+cu128-cp311-cp311-manylinux2014_x86_64.whl`
- **Action**: Detect CUDA version, download correct wheel

**Caution 2: SageAttention**
- Windows wheel (win_amd64) not available on Linux
- **Action**: Try Linux manylinux wheel, fallback to source build

**Caution 3: llama-cpp-python**
- May require compilation on Linux
- **Action**: Attempt pre-built wheel, fallback to source build

**Caution 4: Environment Variables**
- Set TRITON_CACHE, TORCH_INDUCTOR_TEMP **BEFORE** pip install
- **Action**: Export before installing packages

**Caution 5: Virtual Environment**
- Windows: `venv\Scripts\activate.bat`
- Ubuntu: `source venv/bin/activate`
- **Action**: Use full path with source command

**Caution 6: File Operations**
- Windows: `xcopy`, `rmdir /S /Q`
- Ubuntu: `cp -r`, `rm -rf`
- **Action**: Use rsync for large copies, rm -rf with caution

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
