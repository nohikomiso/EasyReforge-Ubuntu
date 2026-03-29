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

### 💡 設計変更の経緯と効率化 (Design Evolution)

当初は 160 個以上の個別 `.sh` ファイルを生成して管理する予定でしたが、今後のメンテナンスコストを最小限に抑えるため、**「データ（CSV）」と「ロジック（Engine）」を完全に切り離す構成**を採用しました。

*   **効率化のポイント**: 
    1.  **管理対象の削減**: 160 個以上のファイルを個別に修正する必要がなくなり、`metadata.csv` の 1 行を修正するだけで全工程に反映されます。
    2.  **動的なフィルタリング**: `download_engine.py` を後付けで実装したことにより、タグ指定（`--tag minimum` 等）一つで、複雑なセット構成を瞬時に切り替えて実行できるようになりました。
    3.  **ディレクトリのクリーン化**: 不要な生成済みスクリプトを排除し、プロジェクト構造を簡潔に保ちます。

---

## Overview

Phase 4 implements a centralized engine to handle bulk downloads for various suites and variants based on metadata.

### Phase 4 Goals
1. **Metadata Enrichment**: Tag CSV entries with variant information (Minimum/Standard/Full).
2. **Download Engine Implementation**: Create a CSV-driven engine for bulk operations.
3. **Meta-Script Implementation**: Create simplified "All" and "Variant" entry points using the engine.
4. **Validation**: Ensure 100% shellcheck compliance and dry-run accuracy.
5. **(Optional) Individual Script Generation**: Tools remain available in `lib/` if individual `.sh` files are needed in the future.

---

## Implementation Checklist

### Before Starting Phase 4
- [x] Phase 3 complete (Download helpers created)
- [x] `metadata.csv` generated from original batch files
- [x] All Phase 3 helpers tested
- [x] Read `docs/03_implementation/03_implementation_common_patterns.md` - Data-Driven section

### Phase 4 Tasks

#### Task 1: Individual Script Generation (Optional/Deprecated)
- **Status**: [x] Generation tools created [x] Clutter cleaned up
- **Note**: Decided to maintain a clean directory by relying on the Engine instead of 160+ manual scripts.

#### Task 2: Metadata Enrichment (Variant Tagging)
- **Goal**: Identify which models belong to "Minimum" and "Standard" variants.
- **Tools**: `Download/lib/tag_metadata.py`
- **Status**: [x] Complete

#### Task 3: Centralized Download Engine
- **File**: `Download/lib/download_engine.py`
- **Capabilities**:
  - [x] Read `metadata.csv`.
  - [x] Filter by category (`--type`).
  - [x] Filter by tag (`--tag`).
  - [x] Support `DRY_RUN=1` environment variable.
- **Status**: [x] Complete

#### Task 4: Meta-Scripts (Category & Variant)
- **Goal**: Provide easy entry points for users.
- **Scripts created** (in `Download/All/`):
  - [x] `AllControlNet.sh`, `AllVAE.sh`, `AllESRGAN.sh`, `Alladetailer.sh`, `AllWildcards.sh`.
  - [x] `AllStable-diffusion.sh`, `AllLora.sh`.
  - [x] `AllModels_Minimum.sh`, `AllModels_Full.sh`.
- **Status**: [x] Complete

#### Task 5: Root-Level Variant Selectors
- **Scripts**: `Download_AllModels_Minimum.sh`, `Download_AllModels_Full.sh`
- **Status**: [x] Complete

---

## Success Criteria

Phase 4 is complete when:
- [x] `metadata.csv` contains accurate `tags` for Minimum/Standard variants.
- [x] `download_engine.py` successfully filters and executes downloads based on CSV.
- [x] `All/*.sh` meta-scripts are thin wrappers around the engine.
- [x] Dry-run mode correctly predicts all downloads for any given variant.
- [x] All new shell scripts pass `shellcheck`.

---

**Last Updated**: 2026-03-29
**Status**: Data-Driven Implementation Complete
