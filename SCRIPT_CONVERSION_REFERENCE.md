# Script Conversion Reference - Windows Batch to Ubuntu Shell

**Quick lookup table for converting Windows batch commands to Ubuntu shell equivalents**

---

## Variable Handling

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `set VAR=value` | `VAR=value` | Local to script |
| `set VAR=value&& echo %VAR%` | `VAR=value; echo "$VAR"` | Use semicolon for sequential |
| `set /p VAR=prompt:` | `read -p "prompt: " VAR` | Interactive input |
| `echo %VAR%` | `echo "$VAR"` | Use quotes to prevent word splitting |
| `echo !VAR!` (delayed expansion) | `echo "${VAR}"` (in same context) | Delayed expansion not needed in bash |
| `%~dp0` | `"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` | Script directory |
| `%~nx1` | `"${1##*/}"` | Basename of parameter |
| `%ERRORLEVEL%` | `$?` | Exit code of last command |
| `%USERNAME%` | `$USER` or `$(whoami)` | Current user |
| `%USERPROFILE%` | `$HOME` | User home directory |
| `%TEMP%` | `$TMPDIR` or `$HOME/.cache` | Temporary directory |

---

## Path and File Operations

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `cd /d C:\path` | `cd /path` | Use forward slashes |
| `pushd dir & popd` | `(cd dir; ...)` | Subshell for isolated directory |
| `if exist path\` | `if [ -d "path/" ]` | Directory exists |
| `if exist file.txt` | `if [ -f "file.txt" ]` | File exists |
| `mkdir dir` | `mkdir -p dir` | Create with parents |
| `del /f file.txt` | `rm -f file.txt` | Force delete |
| `rmdir /s /q dir` | `rm -rf dir` | Recursive delete (CAREFUL!) |
| `copy /y src dst` | `cp src dst` | Copy file |
| `xcopy /sqy src\ dst\` | `cp -r src/* dst/` or `rsync -av src/ dst/` | Copy directory |
| `ren oldname newname` | `mv oldname newname` | Rename/move |
| `move /y src dst` | `mv src dst` | Move file/dir |
| `findstr "pattern" file` | `grep "pattern" file` | Find text in file |
| `findstr /r "regex" file` | `grep -E "regex" file` | Regex search |
| `for /d %%d in (dir\*)` | `for dir in dir/*/; do ... done` | Loop over directories |
| `for /r %%f in (*.ext)` | `find . -name "*.ext" -type f` | Recursive find files |
| `dir /s` | `ls -R` or `find .` | List recursively |
| `cd /d %~dp0` | `cd "$(dirname "${BASH_SOURCE[0]}")"` | Change to script dir |

---

## String Operations

| Windows Batch | Ubuntu Bash | Notes |
|--------------|-------------|-------|
| `%VAR:old=new%` | `${VAR//old/new}` | Replace all occurrences |
| `%VAR:~0,5%` | `${VAR:0:5}` | Substring (first 5 chars) |
| `%VAR:~-3%` | `${VAR: -3}` | Last 3 characters |
| `call :label` | `function_name` | Function call |
| `setlocal enabledelayedexpansion` | Not needed in bash | Delayed expansion handled automatically |
| `%random%` | `$RANDOM` | Random number 0-32767 |
| `if "%VAR%"=="" ` | `if [ -z "$VAR" ]` | Empty string check |
| `if not "%VAR%"=="" ` | `if [ -n "$VAR" ]` | Non-empty check |
| `if /i "%VAR%"=="value"` | `if [ "${VAR,,}" = "value" ]` | Case-insensitive (bash 4+) |

---

## Conditional Logic

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `if condition (...)` | `if condition; then ... fi` | Basic if-then |
| `if not condition (...)` | `if ! condition; then ... fi` | Negation with ! |
| `if condition (...) else (...)` | `if condition; then ... else ... fi` | If-else |
| `if %ERRORLEVEL% neq 0` | `if [ $? -ne 0 ]` | Check exit code |
| `if exist path (...)` | `if [ -d "path" ]; then ... fi` | Path exists |
| `if /i %VAR%==value` | `if [ "$VAR" = "value" ]` | String equality |
| `if "%VAR%"=="" (...)` | `if [ -z "$VAR" ]; then ... fi` | Empty string |
| `if defined VAR` | `if [ -n "${VAR:-}" ]` | Variable defined |
| `if %VAR% geq 5` | `if [ "$VAR" -ge 5 ]` | Numeric comparison |
| `goto label` | `function_name` or `return` | Jump to label |

---

## Numeric Operations

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `set /a num=5+3` | `num=$((5+3))` | Arithmetic expansion |
| `if %num% gtr 10` | `if [ "$num" -gt 10 ]` | Greater than |
| `if %num% lss 10` | `if [ "$num" -lt 10 ]` | Less than |
| `if %num% equ 10` | `if [ "$num" -eq 10 ]` | Equal |

---

## Loops

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `for %%i in (1 2 3)` | `for i in 1 2 3; do ... done` | Loop over list |
| `for /l %%i in (1,1,5)` | `for i in {1..5}; do ... done` | Numeric range |
| `for /d %%d in (*)` | `for dir in */; do ... done` | Loop directories |
| `for /r %%f in (*.txt)` | `while IFS= read -r f; do ... done < <(find . -name "*.txt")` | Recursive file loop |
| `for /f "tokens=1" %%a in (file)` | `while IFS= read -r a rest; do ... done < file` | Line parsing |

---

## Functions & Subroutines

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `:label` ... `call :label` | `function_name() { ... } function_name` | Function definition |
| `exit /b 0` | `return 0` | Return from function |
| `exit /b 1` | `return 1` | Return with error |
| `setlocal` | `local var=value` in function | Local scope |
| `%~1` | `"$1"` | First argument |
| `%~dp0` | `"$(dirname "${BASH_SOURCE[0]}")"` | Script directory |
| `%*` | `"$@"` | All arguments (quoted) |
| `%#` | `$#` | Argument count |

---

## Output & Logging

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `echo message` | `echo "message"` | Print line |
| `echo. ` | `echo ""` | Blank line |
| `echo off` | (no equivalent) | Bash runs quietly by default |
| `cls` | `clear` | Clear screen |
| `echo message > file` | `echo "message" > file` | Redirect to file (overwrites) |
| `echo message >> file` | `echo "message" >> file` | Append to file |
| `echo %VAR% 2>&1 | tee log.txt` | `echo "$VAR" \| tee log.txt` | Output and log |
| `color 0a` | (no equivalent) | No color in shell scripts |
| `@echo off` | (no equivalent) | Use "set +x" if debugging |

---

## Git Operations

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `git clone URL` | `git clone URL` | Clone repo |
| `git fetch origin` | `git fetch origin` | Fetch updates |
| `git reset --hard` | `git reset --hard` | Reset to HEAD |
| `git reset --hard COMMIT` | `git reset --hard COMMIT` | Reset to specific commit |
| `git checkout branch` | `git checkout branch` | Switch branch |
| `git config user.name` | `git config user.name` | Same on all platforms |

---

## Network Operations

| Windows Batch | Ubuntu Shell | Notes |
|--------------|-------------|-------|
| `C:\Windows\System32\curl.exe` | `curl` | Use system curl |
| `curl -L URL` | `curl -L URL` | Follow redirects |
| `curl -o output URL` | `curl -o output URL` | Save to file |
| `curl -fL URL` | `curl -fL URL` | Fail on HTTP error |
| `powershell -Command "(New-Object Net.WebClient).DownloadFile('URL','file')"` | `curl -L -o file URL` | Download file |

---

## Environment Variables

| Windows | Ubuntu | Purpose |
|---------|--------|---------|
| `%APPDATA%\.triton\cache` | `$HOME/.triton/cache` | Triton compilation cache |
| `%TEMP%\torchinductor_%USERNAME%` | `$HOME/.cache/torch/inductor_$(whoami)` | PyTorch cache |
| `chcp 65001` | `export LC_ALL=C.UTF-8` | UTF-8 encoding |
| `%CUDA_PATH%` | `$CUDA_HOME` or auto-detect | CUDA toolkit location |
| `%PYTHONPATH%` | `export PYTHONPATH=...` | Python module path |

---

## Error Handling Patterns

| Windows Batch | Ubuntu Shell | Use Case |
|--------------|-------------|----------|
| `if %ERRORLEVEL% neq 0 (...)` | `if [ $? -ne 0 ]; then ... fi` | Check last command |
| `command || exit /b 1` | `command \|\| exit 1` | Exit on error |
| `setlocal enabledelayedexpansion` | `set -euo pipefail` | Strict mode |
| `call :error_label` | Structured with trap | Error handling |
| N/A | `trap 'cleanup' EXIT` | Cleanup on exit |
| N/A | `set -e` | Exit on first error |

---

## Common Batch Patterns → Shell Equivalents

### Pattern 1: Safe Directory Navigation

**Batch**:
```batch
pushd %~dp0..\..\Model
REM ... operations ...
popd
```

**Shell** (equivalent):
```bash
(
    cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/Model"
    # ... operations ...
)
```

---

### Pattern 2: Conditional Script Execution

**Batch**:
```batch
if exist setup.bat (
    call setup.bat
) else (
    echo Setup script not found
    exit /b 1
)
```

**Shell**:
```bash
if [ -f setup.sh ]; then
    bash setup.sh
else
    echo "Setup script not found" >&2
    exit 1
fi
```

---

### Pattern 3: Safe Variable Expansion

**Batch**:
```batch
setlocal enabledelayedexpansion
for %%f in (*.txt) do (
    echo !DATE! - %%f >> log.txt
)
```

**Shell**:
```bash
for f in *.txt; do
    echo "$(date) - $f" >> log.txt
done
```

---

### Pattern 4: Error Propagation

**Batch**:
```batch
call some_script.bat
if %ERRORLEVEL% neq 0 (
    echo Error in some_script
    exit /b %ERRORLEVEL%
)
```

**Shell** (use `set -e`):
```bash
#!/bin/bash
set -e
trap 'echo "Error in some_script"; exit 1' ERR

some_script.sh

# Rest of script only runs if some_script succeeds
```

---

### Pattern 5: Interactive Input

**Batch**:
```batch
set /p CHOICE="Enter your choice: "
if "%CHOICE%"=="1" (
    REM ...
)
```

**Shell**:
```bash
read -p "Enter your choice: " CHOICE

case "$CHOICE" in
    1)
        # ...
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
```

---

### Pattern 6: File Existence Check & Creation

**Batch**:
```batch
if not exist dir (
    mkdir dir
)
cd dir
```

**Shell**:
```bash
mkdir -p dir
cd dir
```

---

### Pattern 7: Recursive Directory Operations

**Batch**:
```batch
for /r %%f in (*.txt) do (
    echo Processing %%f
    REM ...
)
```

**Shell**:
```bash
find . -name "*.txt" -type f | while read f; do
    echo "Processing $f"
    # ...
done
```

---

### Pattern 8: Configuration File Updates

**Batch**:
```batch
setlocal enabledelayedexpansion
for /f "tokens=1,* delims==" %%a in (config.txt) do (
    if "%%a"=="KEY" (
        echo KEY=newvalue >> output.txt
    ) else (
        echo %%a=%%b >> output.txt
    )
)
```

**Shell** (with sed):
```bash
sed 's/^KEY=.*/KEY=newvalue/' config.txt > output.txt
```

---

## Common Gotchas & How to Avoid Them

### Gotcha 1: Unquoted Variables

**Wrong**:
```bash
echo $VAR          # Breaks if VAR contains spaces
cd $SCRIPT_DIR     # Fails if path has spaces
```

**Right**:
```bash
echo "$VAR"        # Safe
cd "$SCRIPT_DIR"   # Always quoted
```

---

### Gotcha 2: Exit Code Lost in Pipeline

**Wrong**:
```bash
set -e
some_command | grep pattern  # If grep finds nothing, script stops!
```

**Right**:
```bash
set -e
some_command | grep pattern || true  # Or handle appropriately
```

---

### Gotcha 3: Wrong Subshell Usage

**Wrong**:
```bash
(cd some_dir; VAR=value)
echo $VAR  # VAR is empty (subshell scope)
```

**Right**:
```bash
cd some_dir
VAR=value
cd -
echo $VAR  # VAR has value
```

---

### Gotcha 4: Relative Paths in Functions

**Wrong**:
```bash
my_function() {
    cd relative/path  # Fails if called from different directory
}
```

**Right**:
```bash
my_function() {
    local original_dir="$(pwd)"
    cd "$(dirname "${BASH_SOURCE[0]}")/relative/path"
    # ... do work ...
    cd "$original_dir"
}
```

---

### Gotcha 5: Script Directory with Symlinks

**Wrong**:
```bash
SCRIPT_DIR="$(dirname "$0")"  # May point to symlink location
```

**Right**:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Resolves symlinks
```

---

### Gotcha 6: Locale Issues

**Wrong**:
```bash
# No locale setup
# Japanese characters in prompts may not display correctly
```

**Right**:
```bash
#!/bin/bash
export LC_ALL=C.UTF-8

# Now Japanese characters work
echo "モデルをダウンロードしています..."
```

---

### Gotcha 7: Missing Error Handling

**Wrong**:
```bash
curl URL -o file
unzip file  # May fail if curl failed
```

**Right**:
```bash
#!/bin/bash
set -euo pipefail

curl URL -o file || { echo "Download failed"; exit 1; }
unzip file || { echo "Unzip failed"; exit 1; }
```

---

## Quick Checklist for Batch Conversion

Before converting each script, ask:

- [ ] Does it set variables? Replace `set` with `VAR=`
- [ ] Does it use `%ERRORLEVEL%`? Replace with `$?` or `set -e`
- [ ] Does it use `pushd/popd`? Replace with subshell `(cd ...)`
- [ ] Does it use `chcp`? Replace with `export LC_ALL=C.UTF-8`
- [ ] Does it use VC Runtime? Remove entirely
- [ ] Does it modify registry? Remove entirely
- [ ] Does it use `%~dp0`? Replace with script dir expansion
- [ ] Does it use `\` paths? Replace with `/`
- [ ] Does it use `call script.bat`? Replace with `bash script.sh`
- [ ] Does it expect interactive input? Use `read -p` instead of `set /p`

---

## References

- **Bash Manual**: https://www.gnu.org/software/bash/manual/
- **ShellCheck**: https://www.shellcheck.net/ (syntax validator)
- **POSIX Shell**: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html

---

This reference should cover 95% of batch-to-shell conversions needed for EasyReforge.
For complex cases, refer to the IMPLEMENTATION_GUIDE.md for more detailed patterns.
