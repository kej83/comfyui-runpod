#!/bin/bash

# Activate virtual environment
source /workspace/ComfyUI/venv/bin/activate

# Optional: download models once if not already done
if [ ! -f /workspace/models/downloaded.flag ]; then
  echo "Downloading models..."
  mkdir -p /workspace/models
  python /workspace/Download_Models.py && touch /workspace/models/downloaded.flag
else
  echo "Models already downloaded."
fi

# Start ComfyUI
python main.py --listen 0.0.0.0 --port 8188
