FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# Install dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python3.10 python3.10-venv python3.10-dev \
        curl git psmisc openssh-client cloudflared \
        wget unzip build-essential && \
    ln -sf python3.10 /usr/bin/python3 && \
    rm -rf /var/lib/apt/lists/*
    
# Set up ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI
WORKDIR /workspace/ComfyUI

# Create venv and activate it
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    python3 -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip uninstall -y torch torchvision torchaudio && \
    pip install --pre torch==2.7.0.dev20250311 torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/nightly/cu121 && \
    pip install \
        https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/flash_attn-2.7.4.post1-cp310-cp310-linux_x86_64.whl \
        https://huggingface.co/MonsterMMORPG/SECourses_Premium_Flash_Attention/resolve/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl && \
    pip install insightface onnxruntime-gpu triton piexif deepspeed requests hf_transfer huggingface_hub accelerate

# Environment variables
ENV HF_HUB_ENABLE_HF_TRANSFER=1

RUN cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager && \
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus && \
    git clone --recursive https://github.com/ssitu/ComfyUI_UltimateSDUpscale && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack comfyui-impact-pack && \
    cd comfyui-impact-pack && \
    . /workspace/ComfyUI/venv/bin/activate && \
    pip install -r requirements.txt

COPY Download_Models.py /workspace/Download_Models.py
RUN . venv/bin/activate && python3 /workspace/Download_Models.py || echo "Skipping model download."

COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

EXPOSE 8188
CMD [ "bash", "/workspace/start.sh" ]
# CMD ["/workspace/start.sh"]
