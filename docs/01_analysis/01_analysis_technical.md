# EasyReforgeInstaller.bat - Comprehensive Analysis

## Document Summary
This document provides a complete breakdown of the EasyReforgeInstaller.bat installer flow, including all called scripts, dependencies, environment configuration, and critical decision points.

**Target File**: `/home/ytsubame/src/EasyReforge-Ubuntu/EasyReforge/EasyReforgeInstaller.bat`
**Type**: Windows batch script (.bat)
**Purpose**: Bootstrap installer for EasyReforge - prepares system and initializes git repositories before calling main setup

---

## 1. MAIN FLOW - Sequential Execution Steps

### Step 1: Environment Initialization (Lines 1-2)
```
@echo off               - Suppress command echo
chcp 65001 > NUL       - Set code page to UTF-8 for Japanese characters
```

### Step 2: Variable Declaration (Lines 4-15)
Defines paths and URLs for the installer:
- `PROJECT_NAME=EasyReforge`
- `PROJECT_SETUP_BAT=%~dp0%PROJECT_NAME%\Setup.bat` → Script to run after repo init
- `PROJECT_MODEL_DOWNLOAD_BAT=%~dp0Download\NoobAiEpsilonPred_Minimum.bat` → Model download script
- `PROJECT_DIR=%~dp0.` → Current installation directory
- `EASY_TOOLS_DIR=%~dp0EasyTools` → Helper scripts location
- `EASY_GIT_DIR=%EASY_TOOLS_DIR%\Git` → Git installation directory
- Git and tools repository URLs and branch

### Step 3: System Prerequisite Checks (Lines 17-43)
**Check 1: where.exe exists** (Lines 17-20)
- Required for finding executables in PATH
- Exit if missing

**Check 2: PowerShell available** (Lines 22-27)
- Needed for path validation
- Version 5.1+ (Windows 10 preinstalled)
- Exit if missing

**Check 3: Path validation** (Lines 32-37)
- PowerShell regex checks: `^[a-zA-Z0-9:_\\/-]+$`
- Rejects paths with special characters (Japanese, symbols, spaces)
- This is critical for batch script compatibility
- Exit if path invalid

**Check 4: curl.exe available** (Lines 39-43)
- Windows System32 curl (built-in since Windows 10)
- Required for downloading portable Git if needed
- Exit if missing

### Step 4: Conflict Detection - WebUI Paths (Lines 46-57)
Checks if any existing installations exist to prevent conflicts:
- `stable-diffusion-webui\` (Automatic1111)
- `stable-diffusion-webui-forge\` (Forge)
- `stable-diffusion-webui-reForge\` (reForge)

Each check: if exists → exit with message

### Step 5: User Confirmation (Lines 59-62)
Bilingual prompt for model download:
```
Japanese: "未成年の方は利用できません。動作に必要なモデルなどをダウンロードします。よろしいですか？"
English: "Download Model etc. Are you sure? [y/n] (default: y)"
Variable: DOWNLOAD_MDOEL_YES_OR_NO
Default: y (empty input)
```

### Step 6: Git Availability Check & Fallback (Lines 64-101)
**Check for system Git** (Line 65-66)
- `where /Q git` - Query without output
- If found: Jump to :EASY_GIT_FOUND

**Portable Git Download** (Lines 69-90)
If system git not found:
1. Define portable git version: `2.48.1`
2. Check if already downloaded to `%EASY_TOOLS_DIR%\env\PortableGit\bin\`
3. If not found:
   - Create directory `%EASY_TOOLS_DIR%\env\`
   - Download from GitHub: `PortableGit-2.48.1-64-bit.7z.exe`
   - Launch installer with PowerShell automation (auto-press Enter)
   - Extract and clean up
4. Add portable git to PATH

**Verify Git Again** (Lines 95-98)
- Double-check git is now available
- Exit if not found

### Step 7: Initialize Git Repositories (Lines 103-107)
Two repository initializations (via :INIT_REPO subroutine):

1. **EasyTools Repository** (Line 103)
   - URL: `https://github.com/Zuntan03/EasyTools`
   - Branch: `main`
   - Directory: `%EASY_TOOLS_DIR%`

2. **EasyReforge Repository** (Line 106)
   - URL: `https://github.com/Zuntan03/EasyReforge`
   - Branch: `main`
   - Directory: `%PROJECT_DIR%`

Both must succeed or installer exits

### Step 8: Run Main Setup (Lines 109-110)
```
call %PROJECT_SETUP_BAT%
```
Calls: `%~dp0EasyReforge\Setup.bat`

### Step 9: Optional Model Download (Lines 112-114)
```
if /i "%DOWNLOAD_MDOEL_YES_OR_NO%" == "n" ( goto :FINALIZE )
call %PROJECT_MODEL_DOWNLOAD_BAT%
```
- If user chose "n": skip model download
- Otherwise: Call `Download\NoobAiEpsilonPred_Minimum.bat`
- Error is NOT checked (line 114 comment shows `@REM if...`)

### Step 10: Finalization (Lines 150-159)
**Enable Long Path Support**
```
reg add "HKCU\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
```
- Allows Windows paths > 260 characters
- Not critical: failure doesn't halt
- Suggests manual fix via `EasyTools/EnableLongPaths.bat`

**Self-Delete**
```
if exist "%~0" ( del "%~0" )
```
- Installer deletes itself after completion
- Cleanup only if it still exists

---

## 2. CALLED SCRIPTS - Execution Order

| Order | Script | Full Path | Purpose | Called From |
|-------|--------|-----------|---------|-------------|
| 1 | (GitHub_CloneOrPull.bat) | `EasyTools\Git\GitHub_CloneOrPull.bat` | Clone/update git repo | INIT_REPO subroutine (indirect) |
| 2 | (Python_Activate.bat) | `EasyTools\Python\Python_Activate.bat` | Activate Python venv | Called by Reforge.bat (downstream) |
| 3 | Setup.bat | `EasyReforge\Setup.bat` | Main setup orchestrator | Line 109 |
| 4a | Reforge.bat | `EasyReforge\Reforge\Reforge.bat` | PyTorch + dependencies | Called by Setup.bat |
| 4b | ReforgeExtension.bat | `EasyReforge\Reforge\ReforgeExtension.bat` | Clone 13 extensions | Called by Setup.bat |
| 4c | ReforgeLink.bat | `EasyReforge\Reforge\ReforgeLink.bat` | Create symlink junctions | Called by Setup.bat |
| 5 | NoobAiEpsilonPred_Minimum.bat | `Download\NoobAiEpsilonPred_Minimum.bat` | Download minimum models | Line 113 (optional) |

**Downstream calls from Setup.bat**:
- SetupForge.bat (if Forge installation exists)
- NoobAiCommon_Minimum.bat (if Model/Stable-diffusion/NoobE exists)
- Multiple individual model download scripts

### :INIT_REPO Subroutine (Lines 118-148)
Called twice for EasyTools and EasyReforge repositories:

**Parameters**:
- `%~1` = Repository directory
- `%~2` = Repository URL
- `%~3` = Branch name

**Operations**:
1. Create directory if missing: `mkdir %INIT_REPO_DIR%`
2. `git init -q` - Initialize git repository
3. Check if remote 'origin' exists
   - If not: `git remote add origin %INIT_REPO_URL%`
4. `git fetch` - Download refs from remote
5. `git switch %INIT_REPO_BRANCH%` (or fallback to `git checkout -b %INIT_REPO_BRANCH%`)
6. Return 0 on success or 1 on failure

---

## 3. KEY OPERATIONS BREAKDOWN

### 3.1 Environment Setup Steps

| Step | Command | Purpose |
|------|---------|---------|
| UTF-8 Support | `chcp 65001 > NUL` | Enable Japanese character display |
| PowerShell Version | `PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass` | Strict versioning, no profile, allow scripts |
| curl Configuration | `C:\Windows\System32\curl.exe -kL` | SSL bypass (-k), follow redirects (-L) |
| PATH Extension | `set "PATH=%PORTABLE_GIT_BIN%;%PATH%"` | Add Git to PATH if using portable version |

### 3.2 Directory Creation Patterns

Created directories (or assumed to exist):
- `%EASY_TOOLS_DIR%` = `%~dp0EasyTools`
- `%EASY_TOOLS_DIR%\env\` (for portable Git)
- `%EASY_TOOLS_DIR%\env\PortableGit\` (extracted from .7z)

Downstream (Setup.bat):
- `stable-diffusion-webui-reForge\` (git clone)
- `stable-diffusion-webui-reForge\extensions\`
- `stable-diffusion-webui-reForge\extensions-backup\`
- `stable-diffusion-webui-reForge\outputs\*` (multiple)
- `stable-diffusion-webui-reForge\models\*` (via junctions)
- `Model\*` (external model directories)
- `OutputReforge\` (symlink target)

### 3.3 Error Handling Approach

**Pattern Used**: Exit immediately on any error
```batch
command
if %ERRORLEVEL% neq 0 ( pause & exit /b 1 )
```

**Notable Exceptions**:
- Line 114: Model download error is NOT checked (commented out)
- Line 154-157: Long path enable failure doesn't halt (only suggests manual fix)
- Portable Git extraction: Uses PowerShell automation with `Start-Sleep` to handle UI

**Error Information**:
- User sees command echoed before execution
- Pause allows reading error output
- Exit code 1 signals failure to parent process

### 3.4 User Interactions (Prompts & Confirmations)

| Line | Interaction | Type | Default |
|------|-------------|------|---------|
| 18 | where.exe missing | Error + exit | N/A |
| 25 | PowerShell missing | Error + exit | N/A |
| 34-35 | Invalid path characters | Error + exit | N/A |
| 41 | curl.exe missing | Error + exit | N/A |
| 47, 51, 55 | WebUI already exists | Error + exit | N/A |
| 60-61 | Download models? | Prompt | 'y' (empty = yes) |
| 83 | Manual Portable Git action | User instruction | Manual |
| 155 | Long path enable failed | Warning | Continue |

---

## 4. DEPENDENCIES

### 4.1 Required System Tools

| Tool | Location | Checked | Purpose | Fallback |
|------|----------|---------|---------|----------|
| where.exe | C:\Windows\System32\ | Line 17 | Find executables | NONE - Exit |
| PowerShell | System PATH | Line 23 | Path validation, Git automation | NONE - Exit |
| curl.exe | C:\Windows\System32\ | Line 39 | Download files | NONE - Exit |
| git | System PATH or portable | Line 65 | Repository operations | Portable Git (download) |

### 4.2 External Repositories

| Repository | URL | Branch | Used For | Downloaded To |
|------------|-----|--------|----------|----------------|
| EasyTools | https://github.com/Zuntan03/EasyTools | main | Helper scripts (GitHub_CloneOrPull, Python_Activate, etc.) | %~dp0EasyTools\ |
| EasyReforge | https://github.com/Zuntan03/EasyReforge | main | Main project files, Setup.bat | %~dp0 (project root) |

### 4.3 External Downloads

| Item | URL | Format | Downloaded To | Condition |
|------|-----|--------|----------------|-----------|
| Portable Git | github.com/git-for-windows/git/releases | .7z.exe | %EASY_GIT_DIR%\env\ | If system git not found |
| VC Redistributable | aka.ms/vs/17/release/vc_redist.x64.exe | .exe | %~dp0vc_redist.x64.exe | Downloaded by Setup.bat |

### 4.4 Required Network Access

- GitHub (clone/fetch repositories)
- GitHub releases (download Portable Git, VC Redist)
- PowerShell execution policy override (-ExecutionPolicy Bypass)

### 4.5 Windows-Specific Prerequisites

- Windows 10+ (for built-in curl, PowerShell 5.1)
- Administrator rights (for HKEY_CURRENT_USER registry edit, optional)
- GPU drivers for CUDA (downstream, in Reforge.bat)
- Python 3.10.x (required downstream by Reforge.bat, strictly 3.10, no 3.11)

---

## 5. CONFIGURATION & STATE MANAGEMENT

### 5.1 Files Created/Modified

| File | Location | By | Type | Purpose |
|------|----------|----|----|---------|
| PortableGit.7z.exe | %EASY_GIT_DIR%\env\ | curl | Downloaded | Portable Git installer |
| git.exe | %EASY_GIT_DIR%\env\PortableGit\bin\ | Installer (.7z) | Extracted | Git binary |
| .git/ | %EASY_TOOLS_DIR%\ | git init | Created | Git repository metadata |
| .git/ | %~dp0 (project root) | git init | Created | Git repository metadata |
| config (git) | %EASY_TOOLS_DIR%\.git\ | git remote add | Modified | Git remote URL |
| config (git) | %~dp0.git\ | git remote add | Modified | Git remote URL |
| objects/refs/* | %EASY_TOOLS_DIR%\.git\ | git fetch | Created | Downloaded refs |
| objects/refs/* | %~dp0.git\ | git fetch | Created | Downloaded refs |
| HEAD | %EASY_TOOLS_DIR%\.git\ | git switch | Modified | Current branch pointer |
| HEAD | %~dp0.git\ | git switch | Modified | Current branch pointer |
| Registry: HKCU\SYSTEM\CurrentControlSet\Control\FileSystem | N/A | reg add | Modified | LongPathsEnabled = 1 (optional) |

### 5.2 Environment Variables Set

During installer execution:
| Variable | Value | Scope | Notes |
|----------|-------|-------|-------|
| PROJECT_NAME | EasyReforge | Local | |
| PROJECT_SETUP_BAT | %~dp0EasyReforge\Setup.bat | Local | |
| PROJECT_MODEL_DOWNLOAD_BAT | %~dp0Download\NoobAiEpsilonPred_Minimum.bat | Local | |
| PROJECT_URL | https://github.com/Zuntan03/EasyReforge | Local | |
| PROJECT_BRANCH | main | Local | |
| PROJECT_DIR | %~dp0. | Local | |
| EASY_TOOLS_DIR | %~dp0EasyTools | Local | |
| EASY_TOOLS_URL | https://github.com/Zuntan03/EasyTools | Local | |
| EASY_TOOLS_BRANCH | main | Local | |
| PS_EXE | PowerShell | Local | |
| PS_CMD | PowerShell -Version 5.1 -NoProfile -ExecutionPolicy Bypass | Local | |
| CURL_EXE | C:\Windows\System32\curl.exe | Local | |
| CURL_CMD | C:\Windows\System32\curl.exe -kL | Local | |
| PORTABLE_GIT_BIN | %EASY_GIT_DIR%\env\PortableGit\bin | Local | Set only if portable git used |
| PORTABLE_GIT_VERSION | 2.48.1 | Local | Set only if portable git used |
| PATH | %PORTABLE_GIT_BIN%;%PATH% | Process (local scope) | Prepends portable git to PATH |
| DOWNLOAD_MDOEL_YES_OR_NO | (user input) | Local | 'y' or 'n' |
| INIT_REPO_DIR, INIT_REPO_URL, INIT_REPO_BRANCH | (subroutine params) | Local | Used in :INIT_REPO |

### 5.3 State Tracked

None explicitly. State is inferred from:
- Directory existence checks
- Git repository state (via `git remote get-url`)
- Registry state (LongPathsEnabled)

---

## 6. EXIT PATHS & ERROR HANDLING

### 6.1 Success Path

```
EasyReforgeInstaller.bat
├─ System checks pass
├─ Git availability confirmed
├─ EasyTools repo initialized
├─ EasyReforge repo initialized
├─ Setup.bat called (line 109)
│  └─ Reforge.bat, ReforgeExtension.bat, ReforgeLink.bat
│     └─ Creates venv, installs PyTorch, clones extensions, creates symlinks
├─ Model download (optional, line 113)
└─ Self-deletes (line 160)
   Exit Code: 0
```

### 6.2 Failure Paths & Exit Codes

| Line | Condition | Action | Exit Code |
|------|-----------|--------|-----------|
| 19 | where.exe not found | pause & exit | 1 |
| 26 | PowerShell not found | pause & exit | 1 |
| 36 | Invalid path characters | pause & exit | 1 |
| 42 | curl.exe not found | pause & exit | 1 |
| 48, 52, 56 | WebUI directory exists | pause & exit | 1 |
| 79, 85, 89, 97 | Portable Git download/extract fails | pause & exit | 1 |
| 104 | EasyTools repo init fails | exit | 1 |
| 107 | EasyReforge repo init fails | exit | 1 |
| 110 | Setup.bat fails | exit | 1 |
| 160 | Successful completion | (self-delete, then exit) | 0 |

### 6.3 Non-Fatal Conditions

| Condition | Behavior |
|-----------|----------|
| Model download fails (line 114) | Continues (error ignored) |
| LongPathsEnabled registry fails | Warns but continues |
| Portable Git self-delete fails | Continues (already completed) |

---

## 7. CRITICAL DECISION POINTS & BRANCHES

```
┌─ START
│
├─► Check System Tools (where.exe, PowerShell, curl)
│   ├─ FAIL ──► Exit 1
│   └─ OK ─────┐
│              │
├─► Validate Path Characters
│   ├─ FAIL ──► Exit 1
│   └─ OK ─────┐
│              │
├─► Check for Conflicting WebUI Installations
│   ├─ FOUND ─► Exit 1
│   └─ NOT FOUND─┐
│                │
├─► User Prompt: Download Models? [y/n]
│   └─ Response stored in %DOWNLOAD_MDOEL_YES_OR_NO%
│
├─► Check for System Git
│   ├─ FOUND ──► Jump to :EASY_GIT_FOUND
│   │
│   └─ NOT FOUND ─►  Download & Install Portable Git
│       ├─ FAIL ─► Exit 1
│       └─ OK ────► Verify git available again
│           ├─ FAIL ─► Exit 1
│           └─ OK ────► Jump to :EASY_GIT_FOUND
│
├─► :EASY_GIT_FOUND
│
├─► Initialize EasyTools Repository
│   ├─ FAIL ─► Exit 1
│   └─ OK ───┐
│            │
├─► Initialize EasyReforge Repository
│   ├─ FAIL ─► Exit 1
│   └─ OK ───┐
│            │
├─► Call Setup.bat
│   ├─ FAIL ─► Exit 1
│   └─ OK ───┐
│            │
├─► Check: DOWNLOAD_MDOEL_YES_OR_NO == "n"?
│   ├─ YES ──► Jump to :FINALIZE (skip model download)
│   │
│   └─ NO (or 'y', default) ─► Call NoobAiEpsilonPred_Minimum.bat
│       └─ (ignore errors - error not checked)
│
├─► :FINALIZE
│
├─► Enable Long Path Support (registry)
│   └─ (error ignored, only warning shown)
│
├─► Self-Delete
│   ├─ EXISTS ─► Delete installer
│   └─ DELETED ─► No action
│
└─ EXIT 0
```

---

## 8. ANALYSIS NOTES FOR UBUNTU MIGRATION

### Critical Considerations for `.sh` Equivalent

1. **Path Validation**: Batch uses PowerShell regex. Shell equivalent needs `[[ $path =~ ... ]]`

2. **Git Fallback**: No need for portable Git on Linux (git almost always available)

3. **UTF-8**: Already default on modern Linux; `chcp 65001` is unnecessary

4. **Curl**: Linux curl is different from Windows; flags remain similar (-k, -L)

5. **Registry**: `reg add` for LongPathsEnabled is Windows-specific; skip on Linux

6. **Symlinks vs Junctions**: Windows MKLINK /J → Linux `ln -s`

7. **Self-Delete**: Shell script can delete itself: `rm "${BASH_SOURCE[0]}"`

8. **Error Handling**: `set -euo pipefail` replaces scattered error checks

9. **PowerShell Automation**: Not available on Linux; remove GUI automation for Git installer

10. **Code Page**: UTF-8 default on Linux; no equivalent needed

### Essential Linux Equivalents

| Windows | Linux | Notes |
|---------|-------|-------|
| `@echo off` | `set +x` (or implicit) | Bash default is quiet |
| `chcp 65001` | `export LC_ALL=C.UTF-8` | Explicit UTF-8 setup |
| `%~dp0` | `"$(dirname "${BASH_SOURCE[0]}")"` | Script directory |
| `set VAR=value` | `VAR=value` | Variable assignment |
| `%VAR%` | `$VAR` | Variable expansion |
| `if exist path` | `if [ -d path ]` or `if [ -f path ]` | File/dir existence |
| `where command` | `command -v command` | Find in PATH |
| `call script.bat` | `bash script.sh` or `source script.sh` | Execute script |
| `.git/HEAD` | `.git/HEAD` | Same |
| `git switch` | `git switch` or `git checkout` | Git (same) |
| `mkdir path` | `mkdir -p path` | Create with parents |
| `curl -kL` | `curl -kL` or `wget` | Download (same) |
| `popd` | `cd -` or `popd` (zsh/bash with set -o posix off) | Change directory |

### Bash-Specific Setup Required

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

export LC_ALL=C.UTF-8
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

---

## 9. COMPLETE VARIABLE MAPPING TABLE

For reference during conversion to shell script:

| Batch Variable | Purpose | Shell Equivalent | Example Value |
|---|---|---|---|
| `%~dp0` | Current script dir (with trailing \) | `"$(dirname "${BASH_SOURCE[0]}")"` | `/home/user/EasyReforge/` |
| `%~0` | Script name with path | `"${BASH_SOURCE[0]}"` | `/home/user/EasyReforge/installer.sh` |
| `%ERRORLEVEL%` | Last command exit code | `$?` | 0 or 1 |
| `%USERNAME%` | Windows username | `$USER` or `$USERNAME` | `ytsubame` |
| `%~nx1` (subroutine param) | Basename of param 1 | `"$(basename "$1")"` | `folder_name` |
| `%~1`, `%~2`, `%~3` | Subroutine params | `$1`, `$2`, `$3` | (positional args) |
| `setlocal enabledelayedexpansion` | Local var scope | `(subshell scope)` | Use `( ... )` |
| `!VAR!` (delayed expansion) | Variable in loop | `$VAR` (no special syntax) | Automatic in bash |

---

## 10. SUMMARY

**EasyReforgeInstaller.bat** is a bootstrap installer that:

1. Checks system prerequisites (where.exe, PowerShell, curl)
2. Validates installation path (alphanumeric + hyphen/underscore only)
3. Detects conflicts (existing WebUI installations)
4. Ensures git availability (downloads portable version if needed)
5. Initializes two git repositories (EasyTools, EasyReforge)
6. Calls Setup.bat to run main installation
7. Optionally downloads minimum models
8. Enables long path support in registry
9. Self-deletes on completion

**Key characteristics**:
- Strict error checking (exit on any failure except model download and registry)
- Extensive prerequisite validation
- Fallback mechanism for Git availability
- UTF-8 support for Japanese UI
- Self-modifying (deletes itself after completion)

**For Ubuntu migration**: Requires complete rewrite due to Windows-specific features (PowerShell, curl path, registry, MKLINK), but logic flow remains similar.

