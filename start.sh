#!/bin/bash
source /workspace/ComfyUI/venv/bin/activate
export HF_HUB_ENABLE_HF_TRANSFER=1
cd /workspace/ComfyUI
python3 main.py --listen 0.0.0.0 --port 8188