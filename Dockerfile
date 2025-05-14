FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# Install system dependencies (no cloudflared here)
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    wget \
    unzip \
    git \
    build-essential \
    psmisc \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Optional: accept HF token (but DO NOT use it during build)
ARG HF_TOKEN
ENV HF_TOKEN=$HF_TOKEN
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /workspace/ComfyUI

WORKDIR /workspace/ComfyUI

# Python environment and dependencies
RUN python -m venv venv && \
    . venv/bin/activate && \
    python -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip uninstall -y torch torchvision xformers torchaudio && \
    pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    pip install insightface onnxruntime-gpu triton piexif deepspeed requests hf_transfer huggingface_hub accelerate

# Custom nodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone https://github.com/rgthree/rgthree-comfy && \
    git clone --recursive https://github.com/ssitu/ComfyUI_UltimateSDUpscale && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack comfyui-impact-pack && \
    cd comfyui-impact-pack && \
    . /workspace/ComfyUI/venv/bin/activate && \
    pip install -r requirements.txt && \
    cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    cd ComfyUI-Impact-Subpack && \
    pip install -r requirements.txt

# Add scripts
COPY start.sh /workspace/start.sh
COPY Download_Models.py /workspace/Download_Models.py

RUN chmod +x /workspace/start.sh

# ❌ Removed model download step to avoid bloat
# RUN . venv/bin/activate && python /workspace/Download_Models.py || echo "Skipping model download."

EXPOSE 8188
CMD ["bash", "/workspace/start.sh"]
