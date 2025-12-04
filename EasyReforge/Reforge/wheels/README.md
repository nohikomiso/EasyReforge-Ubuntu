# SageAttention Wheels for Linux

## Overview

This directory contains pre-built Linux wheels for the SageAttention library, which provides optimized attention mechanisms for PyTorch models.

## Wheels Included

- **sageattention-2.2.0-cp310-cp310-linux_x86_64.whl**: Python 3.10 on Linux x86_64

## Installation

```bash
pip install sageattention-2.2.0-cp310-cp310-linux_x86_64.whl
```

## Verification

```bash
python -c "from sageattention import sageattn; print('✓ SageAttention loaded')"
```

## Building from Source

If you need to rebuild SageAttention for a different configuration:

```bash
git clone https://github.com/woct0rdho/SageAttention.git
cd SageAttention
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install -e .
```

## Notes

- SageAttention is a performance optimization for PyTorch
- If the wheel is not available, the system will skip installation (non-critical)
- Requires NVIDIA GPU with CUDA support
- Python 3.10.x only (cp310)

## License

See the SageAttention repository for license information: https://github.com/woct0rdho/SageAttention
