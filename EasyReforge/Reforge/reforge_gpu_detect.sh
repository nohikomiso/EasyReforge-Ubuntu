#!/bin/bash
# reforge_gpu_detect.sh - Auto GPU Optimization Detection
#
# Purpose: Detects the installed NVIDIA GPU and sets optimized COMMANDLINE_ARGS.
# Logic: Based on the original Windows projekt's behavior (RTX 30/40/50 etc.)
#

set -euo pipefail

# Initialize empty args if not set
export COMMANDLINE_ARGS="${COMMANDLINE_ARGS:-}"

detect_gpu_optimizations() {
    if ! command -v nvidia-smi &>/dev/null; then
        echo "➔ [Auto-GPU] No NVIDIA GPU detected. Using CPU mode."
        export COMMANDLINE_ARGS="--use-cpu all --precision full --no-half --skip-torch-cuda-test ${COMMANDLINE_ARGS}"
        return 0
    fi

    local gpu_name
    gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    echo "➔ [Auto-GPU] Detected: $gpu_name"

    # Optimization mapping based on GPU generation
    local opts=""

    if [[ "$gpu_name" =~ "RTX 50" || "$gpu_name" =~ "RTX 40" ]]; then
        # Ada Lovelace / Blackwell
        echo "➔ [Auto-GPU] Applying RTX 40/50 Series (Ada/Blackwell) Optimizations."
        opts="--opt-sdp-attention --pin-shared-memory --cuda-malloc --cuda-stream"
    elif [[ "$gpu_name" =~ "RTX 30" ]]; then
        # Ampere
        echo "➔ [Auto-GPU] Applying RTX 30 Series (Ampere) Optimizations."
        opts="--opt-sdp-no-mem-attention --pin-shared-memory --cuda-malloc"
    elif [[ "$gpu_name" =~ "RTX 20" || "$gpu_name" =~ "GTX 16" ]]; then
        # Turing
        echo "➔ [Auto-GPU] Applying Turing Series (RTX 20/GTX 16) Optimizations."
        opts="--opt-sdp-no-mem-attention --pin-shared-memory"
    else
        # Default for other NVIDIA GPUs
        echo "➔ [Auto-GPU] Applying Generic NVIDIA Optimizations."
        opts="--opt-sdp-no-mem-attention"
    fi

    # Prepend optimizations to existing args
    export COMMANDLINE_ARGS="${opts} ${COMMANDLINE_ARGS}"
}

detect_gpu_optimizations
