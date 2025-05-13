#!/bin/bash
set -e  # Exit immediately if a command fails

source /workspace/ComfyUI/venv/bin/activate
export HF_HUB_ENABLE_HF_TRANSFER=1

# Check for a flag file directly inside /workspace/ComfyUI
FLAG_FILE="/workspace/ComfyUI/models_downloaded.flag"

if [ ! -f "$FLAG_FILE" ]; then
  echo "Downloading models to /workspace/ComfyUI..."
  python3 /workspace/Download_Models.py && touch "$FLAG_FILE"
else
  echo "Models already downloaded."
fi

cd /workspace/ComfyUI
python3 main.py --listen 0.0.0.0 --port 8188
