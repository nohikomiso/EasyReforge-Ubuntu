# EasyReforge Ubuntu Migration - Implementation Guide

**Purpose**: Step-by-step implementation instructions with detailed notes and cautions
**Target Audience**: Developers implementing the batch-to-shell conversion
**Last Updated**: 2025-12-03

---

## Table of Contents

1. [Before You Start](#before-you-start)
2. [Implementation Order](#implementation-order)
3. [Phase 1: Foundation Scripts (Weeks 1-2)](#phase-1-foundation-scripts-weeks-1-2)
4. [Phase 2: Core Environment (Weeks 3-4)](#phase-2-core-environment-weeks-3-4)
5. [Phase 3: Download Helpers (Weeks 5-6)](#phase-3-download-helpers-weeks-5-6)
6. [Phase 4: Model Scripts (Weeks 7-8)](#phase-4-model-scripts-weeks-7-8)
7. [Phase 2b: Model Linking (Weeks 9-10, Parallel)](#phase-2b-model-linking-weeks-9-10-parallel)
8. [Phase 5: Optional Launchers (Weeks 11-12)](#phase-5-optional-launchers-weeks-11-12)
9. [Common Patterns & Conventions](#common-patterns--conventions)
10. [Troubleshooting](#troubleshooting)
11. [Testing Checklist](#testing-checklist)

---

## Before You Start

### Read These Files First

1. **`.claude/CLAUDE.md`** - Project context and guidelines
   - Read completely to understand architecture patterns
   - Note: This file overrides all default behavior

2. **`TODO.md`** - High-level implementation plan
   - Reference for overall timeline and scope

3. **Original batch files** - For exact logic to replicate
   - Always check the original .bat for correct behavior
   - Don't trust assumptions; verify against source

### System Setup

**Ensure you have**:
```bash
# Required tools
git --version          # Should be 2.25+
bash --version         # Should be 4.0+
python3 --version      # Should be 3.8+
shellcheck --version   # For validation (optional but recommended)

# Git configuration
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Create a branch for this work
git checkout -b ubuntu-migration
```

### Code Style & Conventions

**Bash Script Conventions** (mandatory):
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe errors

# Trap errors for cleanup
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Script directory (use this pattern everywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper files
source "${SCRIPT_DIR}/../lib/common.sh"

# Functions use snake_case
my_function_name() {
    local var_name="$1"  # Use local for function vars
    echo "$var_name"
}

# Main script logic
main() {
    # Implementation here
}

main "$@"
```

**Naming Conventions**:
- Scripts: `lowercase_with_underscores.sh` (not CamelCase)
- Functions: `lowercase_with_underscores()`
- Variables: `UPPERCASE_WITH_UNDERSCORES` (constants), `lowercase_with_underscores` (locals)
- Helper directory: `lib/` (not `helpers/` or `utils/`)

**Comments & Documentation**:
- Add comments for non-obvious logic only
- Document parameters in function headers:
  ```bash
  # Create a symlink with error handling
  # Usage: create_symlink <link_path> <target_path>
  # Args:
  #   $1: Link destination path (will be created)
  #   $2: Target source path (must exist)
  # Returns: 0 on success, 1 on failure
  create_symlink() {
      ...
  }
  ```

---

## Implementation Order

### Strict Sequential Order (IMPORTANT)

⚠️ **MUST follow this order** - Dependencies require previous phases completed:

```
WEEK 1-2: PHASE 1
  [Start] Helper: GitHub_CloneOrPull.sh
    ↓
  [Wait] GitHub_CloneOrPull.sh complete + tested
    ↓
  [Start] Helper: Python_Activate.sh
    ↓
  [Parallel] easyreforge_installer.sh, update.sh, setup.sh (depend on helpers)

WEEK 3-4: PHASE 2
  [Start] Helper: link_helper.sh (for reforge_link.sh)
    ↓
  [Parallel after helper] reforge.sh, reforge_extension.sh, reforge_link.sh
    ↓
  [After linking complete] reforge_config.sh, reforge_ui_config.sh
    ↓
  [Last] reforge.sh (root launcher)

WEEK 5-6: PHASE 3
  [Sequential] Create 6 helper libraries in Download/lib/
    - common.sh (all others depend on this)
    - civitai_download.sh
    - huggingface_download.sh
    - civitai_download_unzip.sh
    - huggingface_hub_download.sh
    - aria_download.sh
    - recursive_call.sh

WEEK 7-8: PHASE 4
  [Parallel] Generate 165+ model scripts (automated)
  [Parallel] Convert 20 meta-scripts manually
  [After generation] Validation & testing

WEEK 9-10: PHASE 2b (can run PARALLEL with Phase 4)
  [Sequential] Create link_input.sh, replicate to 7 categories
  [Sequential] Create link_output.sh, replicate to 7 categories
  [Test] Symlink creation and validation

WEEK 11-12: PHASE 5
  [Parallel] Convert launcher variants
  [Parallel] Convert optional scripts
  [Final] End-to-end testing, documentation
```

**Parallel Strategy**: You can work on Phase 3-5 while Phase 2 is being tested. Phase 2 must complete before user-facing testing.

---

## Phase 1: Foundation Scripts (Weeks 1-2)

### Task 1: Create GitHub_CloneOrPull.sh Helper

**File**: `EasyReforge/src/lib/github.sh` OR `EasyTools/Git/github.sh`

**Cautions**:
- This is used by many scripts - must be robust
- Handle both first-clone and subsequent-pull scenarios
- Network errors should be graceful with retries
- Verify commit actually exists before checking out

**Implementation Notes**:
```bash
#!/bin/bash
# Parameters: OWNER REPO BRANCH COMMIT_HASH

# CAUTION 1: Check if directory exists BEFORE git operations
if [ -d "$REPO_DIR/.git" ]; then
    # Already cloned - update it
    cd "$REPO_DIR"
    git fetch origin || exit 1
    # CAUTION 2: Verify branch exists before checkout
    git rev-parse --verify "$BRANCH" || exit 1
    git checkout "$BRANCH" || exit 1
    git reset --hard "$COMMIT_HASH" || exit 1
else
    # First clone
    # CAUTION 3: Clone with depth=1 for speed if branch == main
    git clone "https://github.com/$OWNER/$REPO.git" "$REPO_DIR" || exit 1
    cd "$REPO_DIR"
    git checkout "$BRANCH" || exit 1
    git reset --hard "$COMMIT_HASH" || exit 1
fi
```

**Testing**:
```bash
# Test 1: Clone scenario
rm -rf /tmp/test_repo
bash github.sh owner repo main abc123def456
[ -d "/tmp/test_repo/.git" ] && echo "PASS: Clone" || echo "FAIL"

# Test 2: Pull/reset scenario
bash github.sh owner repo main xyz789uvw012
git -C /tmp/test_repo rev-parse HEAD | grep xyz789 && echo "PASS: Reset" || echo "FAIL"
```

---

### Task 2: Create Python_Activate.sh Helper

**File**: `EasyReforge/src/lib/python.sh`

**Cautions**:
- Virtual environment must use python3 (not python)
- Location must be consistent with reforge.sh expectations
- Activation script path differs on macOS/Linux
- Handle case where python3 is not available

**Implementation Notes**:
```bash
#!/bin/bash
# Creates and activates Python venv

VENV_DIR="${1:-.}/venv"  # Default to ./venv

# CAUTION 1: Use python3 explicitly
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 not found" >&2
    exit 1
fi

# CAUTION 2: Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [ "${PYTHON_VERSION%.*}" -lt 3 ] || [ "${PYTHON_VERSION#*.}" -lt 8 ]; then
    echo "Error: Python 3.8+ required, found $PYTHON_VERSION" >&2
    exit 1
fi

# CAUTION 3: Create venv if not exists
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR" || exit 1
fi

# CAUTION 4: Source activation (return the path, don't activate directly)
# Allow calling script to activate from correct directory
echo "$VENV_DIR"
```

**Usage Pattern**:
```bash
VENV_DIR=$(source python.sh)
source "$VENV_DIR/bin/activate"
```

**Testing**:
```bash
# Test venv creation
VENV=$(bash python.sh /tmp/test_venv)
[ -f "$VENV/bin/activate" ] && echo "PASS: venv created" || echo "FAIL"

# Test activation
source "$VENV/bin/activate"
python3 -c "import sys; sys.exit(0 if 'venv' in sys.prefix else 1)" && echo "PASS: activated" || echo "FAIL"
deactivate
```

---

### Task 3: Convert easyreforge_installer.sh ⭐ START HERE

**File**: `EasyReforge/easyreforge_installer.sh`

**Critical Cautions**:

1. **PowerShell path validation (Lines 32-37)**
   - Windows: Uses PowerShell script to validate long paths support
   - Ubuntu: Long paths always supported natively
   - Action: Remove entire block, don't replace

2. **Portable Git handling (Lines 64-101)**
   - Windows: Downloads standalone git if not installed
   - Ubuntu: Use system apt-get
   - Action: Add apt-get fallback check

3. **VC Runtime (Lines 17-27, 39-44)**
   - Windows: Required for Python wheel compilation
   - Ubuntu: Not needed, skip completely
   - Action: Remove, don't replace

4. **Registry Long Paths (Lines 152-158)**
   - Windows: Modifies registry for >260 char paths
   - Ubuntu: Not applicable
   - Action: Remove entire block

5. **Path handling**
   - Windows: `%~dp0` gets script directory
   - Ubuntu: Use `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
   - Caution: Must handle symlinked scripts correctly

6. **Character encoding**
   - Windows: `chcp 65001 > NUL` sets UTF-8
   - Ubuntu: Set `export LC_ALL=C.UTF-8`
   - Action: Add locale check, not codepage

**Implementation Pattern**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate environment
validate_environment() {
    # Check locale
    export LC_ALL=C.UTF-8

    # Check required commands
    command -v git &>/dev/null || {
        echo "Error: git not installed"
        echo "Install with: sudo apt-get install -y git"
        exit 1
    }

    command -v curl &>/dev/null || {
        echo "Error: curl not installed"
        echo "Install with: sudo apt-get install -y curl"
        exit 1
    }
}

# Clone repositories
clone_repos() {
    # CAUTION: Use relative paths within repo
    # This allows moving entire directory without breaking
    if [ ! -d "$SCRIPT_DIR/../../../EasyTools" ]; then
        echo "Cloning EasyTools..."
        git clone https://github.com/user/EasyTools.git "$SCRIPT_DIR/../../../EasyTools"
    fi

    # Current repo should already be initialized
    # But validate it
    if [ ! -d "$SCRIPT_DIR/../../.git" ]; then
        echo "Error: Not in a git repository"
        exit 1
    fi
}

main() {
    validate_environment
    clone_repos
    # Call setup.sh
    bash "$SCRIPT_DIR/setup.sh"
}

main "$@"
```

**Testing**:
```bash
# Test in clean directory
rm -rf /tmp/test_easyreforge
mkdir -p /tmp/test_easyreforge
cd /tmp/test_easyreforge
git init
git clone . test_repo
cd test_repo

# Run installer (will fail at setup.sh since not real repo, but validates script)
bash EasyReforge/easyreforge_installer.sh 2>&1 | head -20
```

---

### Task 4: Convert update.sh

**File**: `Update.bat` → `update.sh`

**Cautions**:

1. **EasyTools path resolution**
   - Must find EasyTools relative to script location
   - Handle both git and non-git scenarios

2. **Git fetch/reset logic**
   - Only update if actually changed
   - Handle case where remote branch doesn't exist
   - Handle detached HEAD state

**Implementation Pattern**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EASY_TOOLS="${SCRIPT_DIR}/../EasyTools"
EASY_REFORGE="$(cd "${SCRIPT_DIR}/.." && pwd)"

update_repo() {
    local repo_path="$1"
    local repo_name="$2"

    if [ ! -d "$repo_path/.git" ]; then
        echo "Error: $repo_name is not a git repository"
        exit 1
    fi

    cd "$repo_path"
    echo "Updating $repo_name..."
    git fetch origin || exit 1
    git reset --hard origin/main || exit 1
}

main() {
    # Update EasyTools if it exists
    if [ -d "$EASY_TOOLS" ]; then
        update_repo "$EASY_TOOLS" "EasyTools"
    fi

    # Update EasyReforge
    update_repo "$EASY_REFORGE" "EasyReforge"

    # Run setup
    bash "${SCRIPT_DIR}/EasyReforge/setup.sh"
}

main "$@"
```

---

### Task 5: Convert setup.sh

**File**: `EasyReforge/Setup.bat` → `EasyReforge/setup.sh`

**Cautions**:

1. **VC Runtime removal**
   - Don't replace, just remove
   - No Windows-specific runtime needed

2. **Script calling order**
   - Must wait for each to complete before next
   - Use error checking between calls

3. **Conditional downloads**
   - Check if model exists before attempting download
   - Allow skip with environment variable

**Implementation Pattern**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    # Call setup scripts in order
    echo "Running reforge.sh..."
    bash "${SCRIPT_DIR}/Reforge/reforge.sh" || exit 1

    echo "Running reforge_extension.sh..."
    bash "${SCRIPT_DIR}/Reforge/reforge_extension.sh" || exit 1

    echo "Running reforge_link.sh..."
    bash "${SCRIPT_DIR}/Reforge/reforge_link.sh" || exit 1

    # Optional: download minimum models
    if [ "${DISABLE_MINIMUM_DOWNLOAD:-0}" != "1" ]; then
        echo "Running minimum model downloads..."
        bash "${SCRIPT_DIR}/../../Download/NoobAiEpsilonPred_Minimum.sh" || true
    fi

    echo "Setup complete!"
}

main "$@"
```

---

## Phase 2: Core Environment (Weeks 3-4)

### ⚠️ CRITICAL: reforge.sh (Reforge/Reforge.sh)

**File**: `EasyReforge/Reforge/reforge.sh`

**This is the most complex script. Extensive cautions apply.**

#### Caution 1: PyTorch Installation for Linux

**Problem**: PyTorch CUDA wheels are platform-specific

**Original (Windows)**:
```batch
pip install torch==2.7.1 torchvision==0.18.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu128
```

**Ubuntu Conversion**:
```bash
# CAUTION: cu128 means CUDA 12.8, but may also be cu121, cu118 depending on system
# Must detect CUDA version first

get_cuda_version() {
    if command -v nvidia-smi &>/dev/null; then
        nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -1
    else
        echo "cpu"  # Fallback to CPU
    fi
}

# Install correct PyTorch version
CUDA_VERSION=$(get_cuda_version)
if [ "$CUDA_VERSION" = "cpu" ]; then
    pip install torch==2.7.1 --index-url https://download.pytorch.org/whl/cpu
else
    pip install torch==2.7.1 --index-url https://download.pytorch.org/whl/cu128
fi
```

#### Caution 2: Wheel Platform-Specific Files

**SageAttention wheel**:
- Windows: `sageattention-2.2.0+cu128torch2.7.1.post2-cp39-abi3-win_amd64.whl`
- Ubuntu: Need Linux version, e.g., `sageattention-2.2.0+cu128torch2.7.1.post2-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl`

**Solution**:
```bash
# Download correct wheel for platform
download_sageattention() {
    local SAGEATTENTION_VERSION="2.2.0+cu128torch2.7.1.post2-cp39-abi3"

    # Try to download Linux version
    local URL="https://github.com/tue-mps/sageattention/releases/download/v2.2.0/"
    local WHEEL_NAME="sageattention-${SAGEATTENTION_VERSION}-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"

    if ! curl -fL -o "$WHEEL_NAME" "${URL}${WHEEL_NAME}"; then
        # Fallback: Try building from source
        echo "Warning: Pre-built wheel not available, attempting source build..."
        pip install sageattention[all] --no-binary sageattention
    else
        pip install "$WHEEL_NAME"
        rm "$WHEEL_NAME"
    fi
}
```

**llama-cpp-python wheel**:
- Same pattern: Windows win_amd64 → Linux manylinux

#### Caution 3: Environment Variables for Compilation

**Original**:
```batch
set TRITON_CACHE=C:\Users\%USERNAME%\.triton\cache
set TORCH_INDUCTOR_TEMP=C:\Users\%USERNAME%\AppData\Local\Temp\torchinductor_%USERNAME%
```

**Ubuntu**:
```bash
# Must set BEFORE pip install for correct caching
export TRITON_CACHE="$HOME/.triton/cache"
export TORCH_INDUCTOR_CACHE="$HOME/.cache/torch"
export TORCH_INDUCTOR_TEMP="$HOME/.cache/torch/inductor_$(whoami)"
mkdir -p "$TRITON_CACHE" "$TORCH_INDUCTOR_TEMP"
```

#### Caution 4: Requirements.txt Compatibility

**Problem**: Some packages may have platform-specific wheels or requirements

**Solution**:
```bash
# Before installing requirements
pip install --upgrade pip setuptools wheel

# Check for known issues with requirements
python3 -m pip check || true  # Show warnings but don't fail

# Install with timeout for slow networks
pip install --default-timeout=1000 -r requirements.txt
```

#### Caution 5: pushd/popd Replacement

**Original**:
```batch
pushd src\stable-diffusion-webui-reForge
... operations ...
popd
```

**Ubuntu** (use subshells):
```bash
(
    cd src/stable-diffusion-webui-reForge
    # ... operations ...
    # Automatically returns to previous directory
)
```

#### Caution 6: File Copy Operations

**Original**:
```batch
xcopy /SQY src\stable-diffusion-webui-reForge\*.* .\
rmdir /S /Q cache_dir
```

**Ubuntu**:
```bash
# Copy with rsync (more reliable than cp)
rsync -av src/stable-diffusion-webui-reForge/ ./

# Or with cp
cp -r src/stable-diffusion-webui-reForge/* ./

# Remove with rm -rf (be CAREFUL with paths!)
rm -rf cache_dir
```

#### Full reforge.sh Template

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_ROOT="${SCRIPT_DIR}/../.."

# Source helpers
source "${REFORGE_ROOT}/src/lib/github.sh"
source "${REFORGE_ROOT}/src/lib/python.sh"

# Setup environment
setup_environment() {
    export LC_ALL=C.UTF-8
    export TRITON_CACHE="$HOME/.triton/cache"
    export TORCH_INDUCTOR_TEMP="$HOME/.cache/torch/inductor_$(whoami)"
    mkdir -p "$TRITON_CACHE" "$TORCH_INDUCTOR_TEMP"
}

# Clone/update reForge WebUI
clone_reforge_webui() {
    echo "Cloning/updating reForge WebUI..."
    github_clone_or_pull \
        "Panchovix" \
        "stable-diffusion-webui-reForge" \
        "main" \
        "19395bf96ccdc605774c76a9fe8cc7145b637128"  # Specific commit from original
}

# Create Python virtual environment
setup_python_venv() {
    echo "Setting up Python virtual environment..."
    VENV_PATH=$(python_activate_venv "${SCRIPT_DIR}/src/venv")

    # Activate venv
    source "${VENV_PATH}/bin/activate"
}

# Install PyTorch
install_pytorch() {
    echo "Installing PyTorch with CUDA 12.8 support..."
    pip install --upgrade pip setuptools wheel

    # Check for NVIDIA GPU
    if command -v nvidia-smi &>/dev/null; then
        echo "NVIDIA GPU detected, installing CUDA version..."
        pip install torch==2.7.1 torchvision==0.18.1 torchaudio==2.7.1 \
            --index-url https://download.pytorch.org/whl/cu128
    else
        echo "No NVIDIA GPU detected, installing CPU version..."
        pip install torch==2.7.1 torchvision==0.18.1 torchaudio==2.7.1 \
            --index-url https://download.pytorch.org/whl/cpu
    fi
}

# Install specialized wheels
install_specialized_wheels() {
    echo "Installing specialized wheels..."

    # Clear caches
    rm -rf "$TRITON_CACHE"/* "$TORCH_INDUCTOR_TEMP"/* || true

    # SageAttention
    pip install sageattention==2.2.0 || {
        echo "Warning: SageAttention installation failed, attempting source build..."
        pip install sageattention --no-binary sageattention
    }

    # llama-cpp-python
    pip install llama-cpp-python==0.3.4 || {
        echo "Warning: llama-cpp-python pre-built wheel not available"
        pip install llama-cpp-python --no-binary llama-cpp-python
    }
}

# Install requirements
install_requirements() {
    echo "Installing Python dependencies from requirements.txt..."
    pip install --default-timeout=1000 -r src/requirements.txt
}

# Copy WebUI files
copy_webui_files() {
    echo "Copying WebUI files..."
    (
        cd src/stable-diffusion-webui-reForge
        rsync -av ./ "${SCRIPT_DIR}/src/stable-diffusion-webui-reForge-deploy/"
    )
}

main() {
    setup_environment
    clone_reforge_webui
    setup_python_venv
    install_pytorch
    install_specialized_wheels
    install_requirements
    copy_webui_files

    echo "reforge.sh completed successfully!"
}

main "$@"
```

**Testing**:
```bash
# Test in clean environment
rm -rf /tmp/test_reforge
mkdir -p /tmp/test_reforge
cd /tmp/test_reforge
git init

# Run minimal test (will fail on some steps without full setup, that's OK)
bash reforge.sh 2>&1 | grep -E "Error|completed|WARNING"
```

---

### Task 2: reforge_extension.sh

**File**: `EasyReforge/Reforge/reforge_extension.sh`

**Cautions**:

1. **Extension ordering**
   - Some extensions may depend on others
   - Install in specific order as per original script

2. **Backup handling**
   - Create `extensions-backup/` directory before renaming
   - Don't overwrite without backing up first

3. **Error handling per extension**
   - If one extension fails, should others continue?
   - Original behavior: Continue on error
   - Recommendation: Continue but log failures

**Implementation Pattern**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_DIR="${SCRIPT_DIR}/src/stable-diffusion-webui-reForge/extensions"

clone_extension() {
    local owner="$1"
    local repo="$2"
    local branch="$3"
    local commit="$4"

    # Source github helper
    source "${SCRIPT_DIR}/../../src/lib/github.sh"

    # Clone/update
    github_clone_or_pull "$owner" "$repo" "$branch" "$commit"
}

backup_extension() {
    local ext_dir="$1"

    if [ -e "$ext_dir" ] && [ ! -L "$ext_dir" ]; then
        local timestamp=$(date +%Y%m%d_%H%M_%S)
        mv "$ext_dir" "${ext_dir}-backup-${timestamp}"
    fi
}

main() {
    mkdir -p "$EXTENSIONS_DIR/extensions-backup"
    cd "$EXTENSIONS_DIR"

    # Clone 13 extensions
    clone_extension "DominikDoom" "a1111-sd-webui-tagcomplete" "main" "abc123..."
    clone_extension "Bing-su" "adetailer" "main" "def456..."
    # ... continue for all 13 extensions ...

    # Backup unsupported extensions
    backup_extension "interrogate-api-webui"
    # ... backup other unsupported ...

    echo "Extensions cloned successfully!"
}

main "$@"
```

---

### Task 3: link_helper.sh

**File**: `EasyReforge/Reforge/src/link_helper.sh`

**Cautions**:

1. **Symlink vs junction semantic differences**
   - Windows junctions are directory-level
   - Linux symlinks can point to files or directories
   - Always use `-d` if absolute certainty it's a directory

2. **Relative path handling**
   - Prefer relative symlinks for portability
   - But validate they work correctly
   - Test from different working directories

3. **UTF-8 in prompts**
   - Scripts may prompt in Japanese
   - Ensure locale is set to UTF-8
   - Test with Japanese model names

**Implementation Pattern**:
```bash
#!/bin/bash

# Check if source exists and is readable
check_source_path() {
    local src="$1"

    if [ ! -e "$src" ]; then
        echo "エラー: ソースパスが見つかりません: $src" >&2
        return 1
    fi

    if [ ! -r "$src" ]; then
        echo "エラー: ソースパスに読み取り権限がありません: $src" >&2
        return 1
    fi

    return 0
}

# Check if destination parent is writable
check_dest_directory() {
    local dst="$1"
    local parent="$(dirname "$dst")"

    if [ ! -d "$parent" ]; then
        echo "エラー: 宛先の親ディレクトリが見つかりません: $parent" >&2
        return 1
    fi

    if [ ! -w "$parent" ]; then
        echo "エラー: 宛先ディレクトリに書き込み権限がありません: $parent" >&2
        return 1
    fi

    return 0
}

# Handle existing symlink or backup existing item
handle_existing_target() {
    local dst="$1"

    if [ -L "$dst" ]; then
        # Already a symlink, remove it
        echo "既存のシンボリックリンクを削除します: $dst"
        rm "$dst"
    elif [ -e "$dst" ]; then
        # Non-symlink item exists, back it up
        local timestamp=$(date +%Y%m%d_%H%M_%S%N)
        local backup="${dst}-backup-${timestamp}"
        echo "既存のアイテムをバックアップします: $dst -> $backup"
        mv "$dst" "$backup"
    fi
}

# Create symlink with error handling
create_symlink() {
    local dst="$1"
    local src="$2"

    # Validate
    check_source_path "$src" || return 1
    check_dest_directory "$dst" || return 1

    # Handle existing
    handle_existing_target "$dst"

    # Create symlink
    if ! ln -s "$src" "$dst"; then
        echo "エラー: シンボリックリンク作成に失敗しました" >&2
        return 1
    fi

    # Verify
    if [ ! -L "$dst" ]; then
        echo "エラー: シンボリックリンク検証に失敗しました" >&2
        return 1
    fi

    echo "シンボリックリンク作成成功: $dst -> $src"
    return 0
}

# Get timestamp for unique names
get_timestamp() {
    date +%Y%m%d_%H%M_%S%N
}

# Interactive path prompt with validation
prompt_for_path() {
    local prompt_text="$1"
    local path_input

    while true; do
        read -p "$prompt_text: " path_input

        if [ -z "$path_input" ]; then
            echo "パスが空です。もう一度入力してください。"
            continue
        fi

        if [ ! -e "$path_input" ]; then
            echo "エラー: パスが見つかりません: $path_input"
            continue
        fi

        echo "$path_input"
        break
    done
}

# Get short name with optional override
prompt_for_name() {
    local default_name="$1"
    local name_input

    read -p "短いリンク名を入力（デフォルト: $default_name）: " name_input

    if [ -z "$name_input" ]; then
        echo "$default_name"
    else
        echo "$name_input"
    fi
}
```

---

### Task 4: reforge_link.sh

**File**: `EasyReforge/Reforge/reforge_link.sh`

**Implementation Pattern**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_SRC="${SCRIPT_DIR}/src/stable-diffusion-webui-reForge"
MODEL_ROOT="$(cd "${SCRIPT_DIR}/../../Model" && pwd)"

# Source link helper
source "${SCRIPT_DIR}/src/link_helper.sh"

create_model_link() {
    local category="$1"
    local webui_path="${REFORGE_SRC}/models/${category}"
    local model_path="${MODEL_ROOT}/${category}"

    # Ensure category directory exists in Model/
    mkdir -p "$model_path"

    # Create link
    create_symlink "$webui_path" "$model_path"
}

main() {
    cd "$REFORGE_SRC" || exit 1

    # Link all model categories
    create_model_link "Stable-diffusion"
    create_model_link "Lora"
    create_model_link "ControlNet"
    create_model_link "VAE"
    create_model_link "ESRGAN"
    create_model_link "adetailer"

    # Link wildcards
    mkdir -p "extensions/sd-dynamic-prompts"
    create_symlink "extensions/sd-dynamic-prompts/wildcards" "${MODEL_ROOT}/wildcards"

    # Create output directories
    mkdir -p "outputs/txt2img-images" "outputs/img2img-images" "outputs/extras-images"
    mkdir -p "outputs/txt2img-grids" "outputs/img2img-grids" "log/images"

    # Create OutputReforge symlink
    create_symlink "outputs/OutputReforge" "outputs"

    # Copy wildcard files
    [ ! -f "${MODEL_ROOT}/wildcards/1girl.txt" ] && \
        cp "${SCRIPT_DIR}/src/1girl.txt" "${MODEL_ROOT}/wildcards/"
    [ ! -f "${MODEL_ROOT}/wildcards/play.txt" ] && \
        cp "${SCRIPT_DIR}/src/play.txt" "${MODEL_ROOT}/wildcards/"

    echo "Model linking completed successfully!"
}

main "$@"
```

---

### Task 5-7: Config, UI Config, Root Launcher

**reforge_config.sh** & **reforge_ui_config.sh**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFORGE_WEBUI="${SCRIPT_DIR}/src/stable-diffusion-webui-reForge"

cd "$REFORGE_WEBUI"

# Activate venv and run migration
source venv/bin/activate
python3 src/reforge_update_config.py  # or reforge_update_ui-config.py
```

**Root reforge.sh launcher**:
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/Reforge_NoOptions.sh" "$@"
```

---

## Phase 3: Download Helpers (Weeks 5-6)

### Critical Implementation Order

**Create in this exact order** (each depends on previous):

1. **common.sh** - All others source this
2. **civitai_download.sh** - Used by 66 scripts
3. **huggingface_download.sh** - Used by 59 scripts
4. **civitai_download_unzip.sh** - Uses civitai_download
5. **huggingface_hub_download.sh** - Alternative HF API
6. **aria_download.sh** - Direct URL download
7. **recursive_call.sh** - Directory recursion

### common.sh Template

```bash
#!/bin/bash
# Shared utilities for all download scripts

# Error handling
error() {
    echo "エラー: $@" >&2
    exit 1
}

# Logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $@"
}

# Validate directory exists
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        log "Creating directory: $dir"
        mkdir -p "$dir" || error "Failed to create directory: $dir"
    fi
}

# Get script directory
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

# Dry-run mode
is_dry_run() {
    [ "${DRY_RUN:-0}" = "1" ]
}
```

### civitai_download.sh Template

```bash
#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# Download model from Civitai
# Usage: civitai_download <model_dir> <filename> <model_id> <version_id>
civitai_download() {
    local model_dir="$1"
    local filename="$2"
    local model_id="$3"
    local version_id="$4"

    ensure_directory "$model_dir"

    local file_path="${model_dir}/${filename}"

    # Skip if already exists
    if [ -f "$file_path" ]; then
        log "Already exists: $file_path"
        return 0
    fi

    local url="https://civitai.com/api/v1/model-versions/${version_id}/download"

    if is_dry_run; then
        log "[DRY-RUN] Would download: $url -> $file_path"
        return 0
    fi

    log "Downloading: $filename"
    curl -L -o "$file_path" "$url" || error "Failed to download: $url"

    [ -f "$file_path" ] || error "Download verification failed"
    log "Downloaded successfully: $filename"
}

civitai_download "$@"
```

---

## Phase 4: Model Scripts (Weeks 7-8)

### Automated Generation Strategy

**Don't manually create 165+ scripts!** Use Python generator:

```python
#!/usr/bin/env python3
"""Generate download scripts from metadata CSV"""

import csv
import os

TEMPLATE = '''#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
source "${{SCRIPT_DIR}}/../../lib/{helper_type}.sh"

{helper_name} "{model_dir}" "{filename}" {params}
'''

def generate_scripts(csv_file):
    with open(csv_file) as f:
        reader = csv.DictReader(f)
        for row in reader:
            template_vars = {
                'helper_type': row['helper_type'],
                'helper_name': row['helper_name'],
                'model_dir': row['model_dir'],
                'filename': row['filename'],
                'params': ' '.join([row[f'param{i}'] for i in range(1, 5) if row.get(f'param{i}')])
            }

            script = TEMPLATE.format(**template_vars)

            output_path = row['path'].replace('.bat', '.sh')
            os.makedirs(os.path.dirname(output_path), exist_ok=True)

            with open(output_path, 'w') as f:
                f.write(script)

            os.chmod(output_path, 0o755)
            print(f"Generated: {output_path}")

if __name__ == '__main__':
    generate_scripts('model_scripts_metadata.csv')
```

---

## Phase 2b: Model Linking (Weeks 9-10, Parallel)

### Task 1: Create link_input.sh Template

**File**: `Model/Stable-diffusion/link_input.sh`

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../EasyReforge/Reforge/src/link_helper.sh"

main() {
    local link_src="${1:-}"
    local link_name

    if [ -z "$link_src" ]; then
        link_src=$(prompt_for_path "参照元のフォルダをドラッグ＆ドロップしてください")
    fi

    link_name=$(basename "$link_src")
    link_name=$(prompt_for_name "$link_name")

    create_symlink "$(pwd)/${link_name}" "$link_src"
}

main "$@"
```

**Replicate to all 7 categories** - script is identical, just lives in different directory.

---

## Phase 5: Optional Launchers (Weeks 11-12)

These are straightforward shell equivalents of batch launchers.

**Pattern**:
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set any launcher-specific variables
export REFORGE_ARGS="--option-name value"

# Call main launcher
source "${SCRIPT_DIR}/Reforge_NoOptions.sh" "$@"
```

---

## Common Patterns & Conventions

### Error Handling Pattern

**Every script should use**:
```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR
```

### Logging Pattern

```bash
log() {
    echo "[$(date +'%H:%M:%S')] $@"
}

log_error() {
    echo "[ERROR] $@" >&2
}
```

### Path Resolution Pattern

```bash
# Always use this for script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# For parent directories
PARENT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

### Conditional Execution Pattern

```bash
# Check command exists
if command -v git &>/dev/null; then
    # Safe to use git
fi

# Check file exists
if [ -f "$filepath" ]; then
    # Safe to read
fi

# Check directory
if [ -d "$dirpath" ]; then
    # Safe to cd into
fi
```

### Dry-Run Pattern

```bash
# Enable with: DRY_RUN=1 script.sh
if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[DRY-RUN] Would execute: command"
else
    command
fi
```

---

## Troubleshooting

### Issue: "command not found"

**Cause**: Command not in PATH or not installed
**Solution**:
```bash
command -v git || {
    echo "git not installed"
    sudo apt-get install -y git
}
```

### Issue: "Permission denied"

**Cause**: Script not executable or no write permission
**Solution**:
```bash
chmod +x script.sh
chmod -R u+w directory/
```

### Issue: "No such file or directory"

**Cause**: Path is wrong (Windows vs Linux), relative path calculated incorrectly
**Solution**:
```bash
# Debug: print actual paths
echo "Script: ${BASH_SOURCE[0]}"
echo "Script dir: $SCRIPT_DIR"
echo "File exists: $(test -f "$filepath" && echo "yes" || echo "no")"
```

### Issue: symlink broken

**Cause**: Target path is wrong (relative vs absolute)
**Solution**:
```bash
# Check symlink target
readlink -f symlink_name  # Shows resolved path
readlink symlink_name     # Shows literal target

# Recreate with correct path
rm symlink_name
ln -s "correct/path" symlink_name
```

### Issue: Python venv activation doesn't work

**Cause**: Venv directory not found or wrong shell
**Solution**:
```bash
# Verify venv exists
ls -la venv/bin/activate

# Source with full path
source "$(pwd)/venv/bin/activate"

# Verify activation
python3 -c "import sys; print(sys.prefix)"  # Should show venv path
```

---

## Testing Checklist

### For Each Script Before Commit

- [ ] **Syntax check**: `shellcheck script.sh`
- [ ] **Run with bash**: `bash script.sh`
- [ ] **Run with sh**: `sh script.sh`
- [ ] **Dry-run mode**: `DRY_RUN=1 script.sh`
- [ ] **Error on failure**: Intentionally break dependency, verify error
- [ ] **Help text**: Script should show usage on `-h` or `--help`
- [ ] **Exit codes**: Verify `$?` is correct (0 success, 1 failure)

### Integration Testing

- [ ] All Phase 1 scripts work together: `easyreforge_installer.sh` → `setup.sh`
- [ ] Phase 2 scripts create valid symlinks that WebUI can use
- [ ] WebUI launches after Phase 2: `reforge_noptions.sh`
- [ ] Model downloads work: `DRY_RUN=1` all download scripts
- [ ] Meta-scripts call all children correctly

### End-to-End Testing (on fresh Ubuntu VM)

1. Clone repository
2. Run `easyreforge_installer.sh`
3. Verify directory structure created
4. Run `setup.sh`
5. Verify Python venv in `src/stable-diffusion-webui-reForge/venv`
6. Run `reforge_noptions.sh`
7. Verify WebUI launches
8. Load NoobE model
9. Generate test image
10. Verify output in OutputReforge

---

## Summary: Implementation Checklist

### Phase 1 (Weeks 1-2)
- [ ] GitHub_CloneOrPull.sh created and tested
- [ ] Python_Activate.sh created and tested
- [ ] easyreforge_installer.sh converted
- [ ] update.sh converted
- [ ] setup.sh converted
- [ ] All Phase 1 scripts integrated and tested

### Phase 2 (Weeks 3-4)
- [ ] link_helper.sh created and tested
- [ ] reforge.sh converted (most critical)
- [ ] reforge_extension.sh converted
- [ ] reforge_link.sh converted
- [ ] reforge_config.sh converted
- [ ] reforge_ui_config.sh converted
- [ ] Root reforge.sh launcher converted
- [ ] Integration test (installer → setup → launch WebUI)

### Phase 3 (Weeks 5-6)
- [ ] 7 helper libraries in Download/lib/ created and tested
- [ ] Metadata extraction tool created
- [ ] CSV metadata generated from all 176 .bat files

### Phase 4 (Weeks 7-8)
- [ ] 165+ model download scripts generated
- [ ] shellcheck validation passes
- [ ] 20 meta-scripts converted
- [ ] 2 composition scripts converted manually
- [ ] Dry-run testing of all download flows

### Phase 2b (Weeks 9-10)
- [ ] link_input.sh created and replicated to 7 categories
- [ ] link_output.sh created and replicated to 7 categories
- [ ] Testing of symlink creation

### Phase 5 (Weeks 11-12)
- [ ] 8 Reforge launcher variants converted
- [ ] 8 LLM inference scripts converted
- [ ] Optional extension launchers converted
- [ ] End-to-end testing on fresh Ubuntu VM
- [ ] Documentation complete
- [ ] Ready for public release

---

**This Implementation Guide provides everything needed to systematically convert 237 batch files to shell scripts while maintaining quality and consistency.**
