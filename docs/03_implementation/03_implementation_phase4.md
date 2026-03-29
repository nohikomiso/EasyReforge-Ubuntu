# Phase 4 Implementation Guide - Model Script Generation

**Status**: Updated for Data-Driven Orchestration (CSV-based)
**Phase**: 4 of 5 (Weeks 7-8)
**Complexity**: MEDIUM (Engine implementation + Metadata management)
**Estimated Time**: 25-30 hours (Reduced by automation)

---

## IMPORTANT: Data-Driven Approach

**Phase 4 follows a "Data Source as Truth" architecture.**

Instead of mimicking the nested Windows batch file calls, we use `Download/metadata.csv` to drive all download operations.

### Mandatory Process

1. **Enhance Metadata (`metadata.csv`)**
   - Add a `tags` column to identify variants (Minimum, Standard, etc.).
   - Ensure `model_type` correctly identifies categories (ControlNet, Lora, etc.).

2. **Implement Unified Download Engine**
   - A single engine (Python or Bash) that reads the CSV and filters rows.
   - It orchestrates calls to the helper libraries (`civitai_download.sh`, etc.).

3. **Create Thin-Wrapper Meta-Scripts**
   - Category-level scripts (e.g., `AllLora.sh`) call the engine with filters.
   - Variant-level scripts (e.g., `Minimum.sh`) call the engine with tag filters.

### Reference Documents
- `.claude/CLAUDE.md` - Script Conversion Guidelines
- `docs/03_implementation/03_implementation_common_patterns.md` - Data-Driven Orchestration
- `Download/metadata.csv` - Single Source of Truth

---

## Overview

Phase 4 generates 160+ individual model scripts for manual use, but primarily implements a centralized engine to handle bulk downloads for various suites and variants.

### Phase 4 Goals
1. **Individual Script Generation**: Generate 160+ .sh scripts for manual, granular model updates.
2. **Download Engine Implementation**: Create a CSV-driven engine for bulk operations.
3. **Metadata Enrichment**: Tag CSV entries with variant information (Minimum/Standard/Full).
4. **Meta-Script Implementation**: Create simplified "All" and "Variant" entry points using the engine.
5. **Validation**: Ensure 100% shellcheck compliance and dry-run accuracy.

---

## Implementation Checklist

### Before Starting Phase 4
- [x] Phase 3 complete (Download helpers created)
- [x] `metadata.csv` generated with 150+ entries
- [x] All Phase 3 helpers tested
- [x] Read `docs/03_implementation/03_implementation_common_patterns.md` - Data-Driven section

### Phase 4 Tasks

#### Task 1: Individual Script Generation
- **File**: `Download/lib/generate_scripts.py`
- **Output**: 160+ .sh scripts in `Download/` subdirectories.
- **Logic**:
  - [x] Read CSV metadata.
  - [x] Generate scripts from template.
  - [x] Set execute permissions (755).

#### Task 2: Metadata Enrichment (Variant Tagging)
- **Goal**: Identify which models belong to "Minimum" and "Standard" variants.
- **Logic**:
  - [ ] Analyze original orchestrators (`NoobAiCommon_Minimum.bat`, etc.).
  - [ ] Add `tags` column to `metadata.csv`.
  - [ ] Populate tags (`minimum`, `standard`).

#### Task 3: Centralized Download Engine
- **File**: `Download/lib/download_engine.py` (or `.sh`)
- **Capabilities**:
  - [ ] Read `metadata.csv`.
  - [ ] Filter by category (`--type`).
  - [ ] Filter by tag (`--tag`).
  - [ ] Support `DRY_RUN=1` environment variable.
  - [ ] Log progress and handle errors gracefully.

#### Task 4: Meta-Scripts (Category & Variant)
- **Goal**: Provide easy entry points for users.
- **Scripts to create** (in `Download/All/`):
  - [ ] `AllControlNet.sh`, `AllVAE.sh`, `AllESRGAN.sh`, `Alladetailer.sh`, `AllWildcards.sh`.
  - [ ] `AllStable-diffusion.sh`, `AllLora.sh`.
  - [ ] `AllModels_Minimum.sh`, `AllModels_Full.sh`.
- **Logic**: Call `download_engine` with appropriate arguments.

#### Task 5: Root-Level Variant Selectors
- **Scripts**: `NoobAiEpsilonPred_Minimum.sh`, `NoobAiVPred_Minimum.sh`, etc.
- **Logic**: Call category-level meta-scripts or engine directly with tag filters.

---

## Implementation Patterns

### Download Engine Call Pattern
Meta-scripts should use this pattern to invoke the engine:

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Invoke engine with specific filter
python3 "${SCRIPT_DIR}/../lib/download_engine.py" --type "ControlNet" "$@"
```

### Variant Tagging Pattern in CSV
The `metadata.csv` should be enhanced as follows:
`script_name,model_type,output_directory,method,params...,tags`
`ApoHotel_Yahiyo_v10,Lora,NoobE_Char,civitai_download,...,minimum;standard`

---

## Success Criteria

Phase 4 is complete when:
- [x] 160+ model scripts generated (for manual update use).
- [ ] `metadata.csv` contains accurate `tags` for Minimum/Standard variants.
- [ ] `download_engine` successfully filters and executes downloads based on CSV.
- [ ] `All/*.sh` meta-scripts are thin wrappers around the engine.
- [ ] Dry-run mode correctly predicts all downloads for any given variant.
- [ ] All new shell scripts pass `shellcheck`.

---

**Last Updated**: 2026-03-29
**Status**: Transitioned to Data-Driven Design
