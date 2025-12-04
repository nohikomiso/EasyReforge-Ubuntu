#!/bin/bash
# verify_versions.sh - Verify all critical dependencies for reForge
# Usage: bash verify_versions.sh
# Purpose: Quick sanity check after installation to ensure all versions match specifications

set -euo pipefail

echo "================================"
echo "reForge Version Verification"
echo "================================"
echo ""

# Python Version Check
echo "=== Python Version ==="
if python --version 2>&1 | grep -q "3.10"; then
    python --version
    echo "✓ Python 3.10.x verified"
else
    echo "✗ ERROR: Python 3.10.x required"
    exit 1
fi
echo ""

# PyTorch Versions
echo "=== PyTorch Framework Versions ==="
python -c "import torch; print(f'PyTorch: {torch.__version__}')" || echo "✗ PyTorch not installed"
python -c "import torchvision; print(f'TorchVision: {torchvision.__version__}')" || echo "✗ TorchVision not installed"
python -c "import torchaudio; print(f'TorchAudio: {torchaudio.__version__}')" || echo "✗ TorchAudio not installed"

# Verify versions match specification (2.7.1, 0.22.1, 2.7.1)
echo ""
echo "=== Version Specification Checks ==="
python << 'PYTHON_SCRIPT'
import torch, torchvision, torchaudio
checks = [
    ('PyTorch', torch.__version__, '2.7.1+cu128'),
    ('TorchVision', torchvision.__version__, '0.22.1+cu128'),
    ('TorchAudio', torchaudio.__version__, '2.7.1+cu128')
]
all_ok = True
for name, actual, expected in checks:
    if expected in actual or actual.startswith(expected.split('+')[0]):
        print(f'✓ {name}: {actual}')
    else:
        print(f'✗ {name}: Expected {expected}, got {actual}')
        all_ok = False
exit(0 if all_ok else 1)
PYTHON_SCRIPT
echo ""

# CUDA Support
echo "=== CUDA Support ==="
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
if python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
    python -c "import torch; print(f'CUDA Version: {torch.version.cuda}')"
    python -c "import torch; print(f'cuDNN Version: {torch.backends.cudnn.version()}')" || echo "⚠ cuDNN version unavailable"
else
    echo "⚠ CUDA not available (CPU-only mode)"
fi
echo ""

# Platform Check
echo "=== Platform Information ==="
python << 'PYTHON_SCRIPT'
import sys, platform
print(f'Python Implementation: {sys.implementation.name}')
print(f'Platform: {sys.platform}')
print(f'Machine: {platform.machine()}')
print(f'OS: {platform.system()} {platform.release()}')
PYTHON_SCRIPT
echo ""

# Optional Dependencies
echo "=== Optional Dependencies ==="
if python -c "from sageattention import sageattn; print('✓ SageAttention available')" 2>/dev/null; then
    :
else
    echo "⚠ SageAttention not available (non-critical performance optimization)"
fi

if python -c "import llama_cpp; print('✓ llama-cpp-python available')" 2>/dev/null; then
    :
else
    echo "⚠ llama-cpp-python not available (non-critical LLM support)"
fi
echo ""

# Wheel Platform Tags
echo "=== Wheel Platform Tags ==="
echo "Checking installed packages are Linux-compatible..."
if pip list -v 2>/dev/null | grep -E "(torch|torchvision|sageattention|llama)" >/dev/null 2>&1; then
    pip list -v 2>/dev/null | grep -E "(torch|torchvision|sageattention|llama)"
else
    echo "No matching packages found"
fi
echo ""

if pip list -v 2>/dev/null | grep -E "(torch|torchvision)" | grep -q "win_amd64"; then
    echo "✗ WARNING: Windows wheels detected!"
    exit 1
else
    echo "✓ All wheels are Linux-compatible"
fi
echo ""

echo "================================"
echo "✓ Verification Complete"
echo "================================"
