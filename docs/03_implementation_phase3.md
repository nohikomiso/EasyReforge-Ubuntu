# Phase 3 Implementation Guide - Download Helpers

**Status**: Template for Phase 3 implementation work
**Phase**: 3 of 5 (Weeks 5-6)
**Complexity**: MEDIUM (7 interdependent helpers)
**Estimated Time**: 30-40 hours

---

## IMPORTANT: Design-First Approach

**DO NOT simply translate batch download scripts to shell.**

Phase 3 creates download helpers. Each must be designed for Ubuntu:

### Mandatory Process

1. **Analyze the original Download/*.bat files' PURPOSE**
   - What API are they calling? (Civitai, HuggingFace, etc.)
   - What parameters do they pass?
   - How do they handle errors?

2. **Study EasyEnv/EasyTools patterns**
   - Reference: `/home/ytsubame/src/_research_reference/ANALYSIS_REPORT.md`
   - Look for download/network handling patterns

3. **Design Ubuntu-native solution**
   - Use `curl` or `wget` (apt-installed, not custom binaries)
   - Use `aria2c` for parallel downloads if needed
   - Proper error handling with exit codes

4. **Invoke `Skill shell-scripting`** for implementation

5. **Syntax lookup**: `04_reference_conversion_table.md` (supplementary only)

### Reference Documents
- `.claude/CLAUDE.md` - Script Conversion Guidelines
- `docs/03_implementation_common_patterns.md` - Batch File Analysis Process

---

## Overview

Phase 3 creates the foundation for 165+ model download scripts. It depends on Phase 1-2 completion.

### Phase 3 Goals
1. Create 7 download helper libraries
2. Extract metadata from 176 .bat files into CSV
3. Build automation framework for Phase 4

---

## Implementation Checklist

### Before Starting Phase 3
- [ ] Phase 1 complete and tested
- [ ] Phase 2 complete and WebUI working
- [ ] Read `docs/03_implementation_common_patterns.md` - Phase 3 section
- [ ] Read `docs/04_reference_conversion_table.md` - Text processing section

### Phase 3 Helper Scripts (Create in Order)

#### Task 1: common.sh
- **File**: `Download/lib/common.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 4-6 hours
- **All other helpers depend on this**
- **Functions needed**:
  - [ ] error() - Error handling
  - [ ] log() - Logging with timestamp
  - [ ] log_error() - Error logging
  - [ ] ensure_directory() - Create dir if missing
  - [ ] get_script_dir() - Get calling script's directory
  - [ ] is_dry_run() - Check DRY_RUN environment variable
  - [ ] validate_url() - Check URL validity
  - [ ] extract_filename_from_url() - Parse filename
- **Tests**:
  - [ ] Error function exits with code 1
  - [ ] Logging outputs to console
  - [ ] Directory creation works
  - [ ] Dry-run mode works
- **Validation**: [ ] Passed shellcheck

#### Task 2: civitai_download.sh
- **File**: `Download/lib/civitai_download.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 6-8 hours
- **Used by**: 66 model scripts
- **Functions needed**:
  - [ ] civitai_download() - Main download function
  - [ ] civitai_get_download_url() - Generate Civitai URL
  - [ ] civitai_verify_api_key() - Validate API key if needed
  - [ ] civitai_handle_rate_limit() - Rate limiting
- **Parameters**: model_dir, filename, model_id, version_id
- **Tests**:
  - [ ] DRY_RUN mode shows download path
  - [ ] Actual download works (test with small model)
  - [ ] Duplicate file detection works
  - [ ] Error handling on network failure
- **Validation**: [ ] Passed shellcheck

#### Task 3: huggingface_download.sh
- **File**: `Download/lib/huggingface_download.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 6-8 hours
- **Used by**: 59 model scripts
- **Functions needed**:
  - [ ] huggingface_download() - Main download
  - [ ] huggingface_list_files() - List repo files
  - [ ] huggingface_get_download_url() - Generate HF URL
- **Parameters**: model_dir, filename, model_id
- **Tests**:
  - [ ] Download from Hugging Face works
  - [ ] File listing works
  - [ ] DRY_RUN mode works
- **Validation**: [ ] Passed shellcheck

#### Task 4: civitai_download_unzip.sh
- **File**: `Download/lib/civitai_download_unzip.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 4-5 hours
- **Used by**: 21 model scripts
- **Functions needed**:
  - [ ] civitai_download_unzip() - Download and extract
- **Depends on**: civitai_download.sh (use its function)
- **Tests**:
  - [ ] Download + unzip works
  - [ ] Cleanup of zip file works
- **Validation**: [ ] Passed shellcheck

#### Task 5: huggingface_hub_download.sh
- **File**: `Download/lib/huggingface_hub_download.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 3-4 hours
- **Used by**: 4 model scripts
- **Functions needed**:
  - [ ] huggingface_hub_download() - Alternative HF API
- **Tests**:
  - [ ] Download works via alternative method
  - [ ] Fallback to standard method if fails
- **Validation**: [ ] Passed shellcheck

#### Task 6: aria_download.sh
- **File**: `Download/lib/aria_download.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 2-3 hours
- **Used by**: 4 model scripts
- **Functions needed**:
  - [ ] aria_download() - Direct URL download
  - [ ] curl_download() - Fallback to curl
- **Tests**:
  - [ ] Direct URL downloads work
  - [ ] Fallback to curl works
- **Validation**: [ ] Passed shellcheck

#### Task 7: recursive_call.sh
- **File**: `Download/lib/recursive_call.sh`
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 3-4 hours
- **Used by**: Meta-scripts (20+ files)
- **Functions needed**:
  - [ ] recursive_call() - Execute all *.sh in directory
  - [ ] find_and_execute() - Find and execute scripts
  - [ ] handle_errors() - Aggregate error reporting
- **Tests**:
  - [ ] Finds all .sh files in directory
  - [ ] Executes in correct order
  - [ ] Error handling works
  - [ ] Progress reporting works
- **Validation**: [ ] Passed shellcheck

### Phase 3 Metadata Tool

#### Task 8: Metadata Extraction Tool
- **File**: Python script to parse .bat files → CSV
- **Status**: [ ] Not started [ ] In progress [ ] Complete
- **Time estimate**: 4-6 hours
- **Input**: All 176 .bat files in Download/
- **Output**: `metadata.csv` with columns:
  - script_name
  - model_type (Stable-diffusion, Lora, ControlNet, etc.)
  - download_method (civitai, huggingface, aria, etc.)
  - civitai_model_id
  - civitai_version_id
  - huggingface_model_id
  - direct_url
  - output_directory
  - helper_library
  - dependencies
- **Logic**:
  - [ ] Parse batch file commands
  - [ ] Extract download URLs
  - [ ] Classify by download method
  - [ ] Extract parameters
  - [ ] Generate CSV rows
- **Tests**:
  - [ ] CSV generated successfully
  - [ ] All 176 .bat files parsed
  - [ ] No duplicate entries
  - [ ] Sample entries validated manually

### Integration Testing
- [ ] All 7 helpers load without errors
- [ ] common.sh can be sourced by all others
- [ ] Dry-run mode works for all downloads
- [ ] Error handling tested (network failures, missing files)
- [ ] Logging works correctly
- [ ] Metadata CSV has all 176+ entries
- [ ] Sample download test passes

### Final Verification
- [ ] All Phase 3 scripts pass shellcheck
- [ ] All helpers have consistent error handling
- [ ] UTF-8 support verified for Japanese paths
- [ ] Dry-run mode works end-to-end
- [ ] Metadata extraction complete
- [ ] Ready for Phase 4 automation

---

## Helper Library Responsibilities

### common.sh (Master)
- Error handling
- Logging utilities
- Directory management
- Utility functions
- **Used by**: All 6 other helpers

### civitai_download.sh
- Civitai API integration
- URL construction
- Authentication if needed
- **Used by**: 66 model scripts

### huggingface_download.sh
- Hugging Face API integration
- Model listing
- Direct downloads
- **Used by**: 59 model scripts

### Other Helpers
- Specialized download methods
- Fallback mechanisms
- Error recovery
- **Used by**: Various model scripts

### recursive_call.sh
- Directory traversal
- Script orchestration
- Error aggregation
- **Used by**: All 20 meta-scripts

---

## Testing Strategy

### Unit Tests (Per Helper)
1. Source the helper script
2. Call each function with test parameters
3. Verify output and exit codes
4. Test error conditions
5. Test dry-run mode

### Integration Tests
1. All helpers source successfully
2. Dry-run mode for all download types
3. Error propagation through call chain
4. Logging aggregation

### Metadata Validation
1. CSV format correct
2. All 176 files parsed
3. No missing fields
4. Sample manual verification

---

## Reference Materials

- **Original files**: Check `Download/*.bat` for download logic
- **Common patterns**: See `docs/03_implementation_common_patterns.md` - Phase 3 section
- **Batch conversions**: Reference `docs/04_reference_conversion_table.md`
- **Metadata format**: See Phase 4 section for expected CSV format

---

## Progress Tracking

**Week 5**:
- [ ] common.sh created (day 1-2)
- [ ] civitai_download.sh created (day 3-4)
- [ ] huggingface_download.sh created (day 5-6)

**Week 6**:
- [ ] civitai_download_unzip.sh created (day 7)
- [ ] Other helpers created (day 8-9)
- [ ] Metadata extraction tool (day 10-11)
- [ ] Testing and integration (day 12+)

---

## Success Criteria

Phase 3 is complete when:
- [ ] All 7 helpers created and pass shellcheck
- [ ] All helpers have consistent error handling
- [ ] Dry-run mode works for all download types
- [ ] Metadata CSV has 176+ entries
- [ ] All fields in CSV populated
- [ ] Sample downloads tested successfully
- [ ] Ready to generate 165+ scripts in Phase 4

---

**Last Updated**: 2025-12-04
**Status**: Template ready for implementation
**Next Phase**: Phase 4 (Model Script Generation - Automated)
