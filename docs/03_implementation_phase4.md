# Phase 4 Implementation Guide - Model Script Generation

**Status**: Template for Phase 4 implementation work
**Phase**: 4 of 5 (Weeks 7-8)
**Complexity**: ⭐⭐ (Low - highly automated)
**Estimated Time**: 30-40 hours

---

## Overview

Phase 4 generates 165+ model download scripts automatically, converts 20 meta-scripts, and validates everything.

### Phase 4 Goals
1. Automatically generate 165+ model scripts from metadata
2. Convert 20 meta-scripts manually
3. Convert 2 composition scripts manually
4. Validate all scripts with shellcheck
5. Test dry-run mode end-to-end

---

## Implementation Checklist

### Before Starting Phase 4
- [ ] Phase 3 complete (Download helpers created)
- [ ] metadata.csv generated with 176+ entries
- [ ] All Phase 3 helpers tested
- [ ] Read `docs/03_implementation_common_patterns.md` - Phase 4 section

### Phase 4 Tasks

#### Task 1: Script Generation Automation
- **File**: Python/Bash script to generate scripts from CSV
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 8-10 hours
- **Input**: metadata.csv (from Phase 3)
- **Output**: 165+ .sh scripts in Download/ directory
- **Logic**:
  - [ ] Read CSV metadata
  - [ ] For each row, generate script from template
  - [ ] Use correct helper library
  - [ ] Set correct parameters
  - [ ] Write to correct directory
  - [ ] Set execute permissions
- **Template Pattern**:
  ```bash
  #!/bin/bash
  set -euo pipefail

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/../../lib/{helper_type}.sh"

  {helper_function} "{model_dir}" "{filename}" {params}
  ```
- **Tests**:
  - [ ] All 165+ scripts generated
  - [ ] Scripts in correct directories
  - [ ] Parameters correct
  - [ ] Permissions set (755)
- **Validation**: [ ] Generation succeeds without errors

#### Task 2: shellcheck Validation (All Generated Scripts)
- **File**: Validation script to check all generated scripts
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 2-3 hours
- **Logic**:
  - [ ] Find all .sh files in Download/
  - [ ] Run shellcheck on each
  - [ ] Report errors
  - [ ] Fix any syntax issues
- **Tests**:
  - [ ] All 165+ scripts pass shellcheck
  - [ ] No errors or warnings
- **Validation**: [ ] 100% pass rate

#### Task 3: Dry-Run Mode Testing
- **File**: Test script to verify DRY_RUN mode
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 3-4 hours
- **Logic**:
  - [ ] Set DRY_RUN=1
  - [ ] Execute each script
  - [ ] Verify output contains "[DRY-RUN]"
  - [ ] Verify no actual downloads occur
- **Tests**:
  - [ ] All 165+ scripts run in dry-run
  - [ ] No actual downloads (verify directory unchanged)
  - [ ] Output shows what would be downloaded
- **Validation**: [ ] All tests pass

#### Task 4: Meta-Scripts Conversion
- **Files**: Convert 12 `All/All*.sh` scripts
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 6-8 hours
- **Pattern**: Use recursive_call.sh to execute all category scripts
- **Scripts to create**:
  - [ ] Download/All/AllStable-diffusion_Minimum.sh
  - [ ] Download/All/AllStable-diffusion_Standard.sh
  - [ ] Download/All/AllStable-diffusion_Full.sh
  - [ ] Download/All/AllLora_Minimum.sh
  - [ ] Download/All/AllLora_Standard.sh
  - [ ] Download/All/AllControlNet.sh
  - [ ] Download/All/AllVAE.sh
  - [ ] Download/All/AllESRGAN.sh
  - [ ] Download/All/Alladetailer.sh
  - [ ] Download/All/AllWildcards.sh
  - [ ] Download/All/AllModels_Minimum.sh
  - [ ] Download/All/AllModels_Full.sh
- **Template**:
  ```bash
  #!/bin/bash
  set -euo pipefail

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/../lib/recursive_call.sh"

  recursive_call "${SCRIPT_DIR}/../Stable-diffusion" "$@"
  ```
- **Tests**:
  - [ ] Each meta-script calls all category scripts
  - [ ] Error handling works
  - [ ] Dry-run mode shows all children
- **Validation**: [ ] All meta-scripts pass shellcheck

#### Task 5: Manual Composition Scripts
- **Files**: Convert 2 composition/orchestrator scripts
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 2-3 hours
- **Scripts**:
  - [ ] Download/src/NoobAiCommon_Minimum.sh (30+ calls)
  - [ ] Download/src/NoobAiCommon_Standard.sh (7+ calls)
- **Logic**:
  - [ ] Chain multiple download scripts
  - [ ] Handle errors between calls
  - [ ] Show progress
  - [ ] Support dry-run mode
- **Tests**:
  - [ ] All chained calls execute
  - [ ] Error propagation works
  - [ ] Dry-run shows all downloads
- **Validation**: [ ] Scripts pass shellcheck

#### Task 6: Root-Level Variant Selectors
- **Files**: Create variant selector scripts at root
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 2-3 hours
- **Scripts**:
  - [ ] NoobAiEpsilonPred_Minimum.sh
  - [ ] NoobAiEpsilonPred_Standard.sh
  - [ ] NoobAiVpred_Minimum.sh
  - [ ] NoobAiVpred_Standard.sh
  - [ ] Download_AllModels_Minimum.sh
  - [ ] Download_AllModels_Full.sh
- **Logic**:
  - [ ] Call appropriate meta-scripts
  - [ ] Support dry-run mode
  - [ ] Show progress
- **Validation**: [ ] Scripts pass shellcheck

### Integration Testing

#### Test 1: All Scripts Exist
- [ ] 165+ generated scripts exist
- [ ] 12 meta-scripts exist
- [ ] 2 composition scripts exist
- [ ] 6 variant selector scripts exist
- [ ] Total: 185+ download scripts

#### Test 2: All Scripts Valid
- [ ] All 185+ pass shellcheck
- [ ] No syntax errors
- [ ] All have proper shebang
- [ ] All have error handling

#### Test 3: Dry-Run End-to-End
- [ ] DRY_RUN=1 on root variant script
- [ ] Shows all downloads that would occur
- [ ] No actual downloads
- [ ] Completes successfully

#### Test 4: Metadata Accuracy
- [ ] Generated scripts match CSV metadata
- [ ] Correct helpers used
- [ ] Correct parameters passed
- [ ] Correct output directories

### Final Verification
- [ ] All 185+ scripts pass shellcheck
- [ ] All scripts have consistent structure
- [ ] Dry-run mode works for all
- [ ] Meta-scripts call all children
- [ ] Error handling in place
- [ ] UTF-8 support verified
- [ ] Ready for Phase 2b + Phase 5

---

## Script Generation Template

All generated scripts follow this pattern:

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/{helper_type}.sh"

# Source common library
source "${SCRIPT_DIR}/../../lib/common.sh"

# Call download function with parameters
{helper_function} "{output_dir}" "{filename}" {additional_params}
```

## Meta-Script Template

All meta-scripts use this pattern:

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/recursive_call.sh"

# Execute all scripts in category directory
recursive_call "${SCRIPT_DIR}/../{category}" "$@"
```

---

## Testing Strategy

### Generation Testing
1. Run generation script on test CSV
2. Verify correct number of files created
3. Verify files in correct locations
4. Spot-check generated content

### Validation Testing
1. shellcheck all 165+ scripts
2. Fix any reported issues
3. Verify 100% pass rate

### Functional Testing
1. DRY_RUN=1 on each script
2. Verify output format correct
3. Verify no actual files downloaded

### Integration Testing
1. Meta-scripts call all children
2. Error handling tested
3. Progress reporting works

---

## Progress Tracking

**Week 7**:
- [ ] Generation script created (day 1-2)
- [ ] 165+ scripts generated (day 3)
- [ ] shellcheck validation (day 4)
- [ ] Dry-run testing begins (day 5)

**Week 8**:
- [ ] Meta-scripts created (day 6-7)
- [ ] Composition scripts created (day 8)
- [ ] Variant selector scripts (day 9)
- [ ] Full integration testing (day 10-12)

---

## Success Criteria

Phase 4 is complete when:
- [ ] 165+ model scripts generated automatically
- [ ] 12 meta-scripts created
- [ ] 2 composition scripts created
- [ ] 6 variant selector scripts created
- [ ] All 185+ scripts pass shellcheck
- [ ] All scripts have correct parameters
- [ ] Dry-run mode works for all scripts
- [ ] Meta-scripts call all children correctly
- [ ] Ready for Phase 2b + Phase 5

---

**Last Updated**: 2025-12-04
**Status**: Template ready for implementation
**Next Phase**: Phase 2b (Model Linking) - Parallel, then Phase 5
