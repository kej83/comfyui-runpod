FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# Install system dependencies (safe for GitHub Actions)
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
    cloudflared \
    && rm -rf /var/lib/apt/lists/*

# Clone and set up ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /workspace/ComfyUI
WORKDIR /workspace/ComfyUI

# Set up virtual environment and install Python packages
RUN python -m venv venv && \
    . venv/bin/activate && \
    python -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip uninstall -y torch torchvision torchaudio && \
    pip install --pre torch==2.7.0.dev20250311 torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/nightly/cu121 && \
    pip install \
        https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl \
        https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl && \
    pip install insightface onnxruntime-gpu triton piexif deepspeed requests hf_transfer huggingface_hub accelerate

ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Install custom nodes
RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone --recursive https://github.com/ssitu/ComfyUI_UltimateSDUpscale && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack comfyui-impact-pack && \
    cd comfyui-impact-pack && \
    . /workspace/ComfyUI/venv/bin/activate && \
    pip install -r requirements.txt

# Add scripts
COPY start.sh /workspace/start.sh
COPY launch.sh /workspace/launch.sh
COPY Download_Models.py /workspace/Download_Models.py

RUN chmod +x /workspace/start.sh /workspace/launch.sh
RUN . venv/bin/activate && python /workspace/Download_Models.py || echo "Skipping model download."

EXPOSE 8188
CMD ["bash", "/workspace/start.sh"]
