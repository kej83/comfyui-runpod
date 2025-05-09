# ComfyUI RunPod Template

This template includes:

- ComfyUI installed from source
- PyTorch nightly with CUDA 12.1
- FlashAttention + SageAttention
- Popular custom nodes preinstalled
- HuggingFace model downloader (via `Download_Models.py`)
- Optional Cloudflare tunnel support via `launch.sh`

## 🧪 Getting Started

1. Launch a Pod from this template
2. ComfyUI will start on port **8188**
3. (Optional) Open a **new terminal** and run:

```bash
bash /workspace/launch.sh
```

This starts a Cloudflare tunnel and prints the public URL.

## 📦 Custom Models

To download custom models, inspect or modify `Download_Models.py`. It will run automatically at startup.

- You can also rerun it manually:

```bash
python3 /workspace/Download_Models.py
```

## 🔐 HuggingFace

The current `Download_Models.py` uses a built-in access token.

If you're building your own version, update the token in the script or use environment variables:

```bash
export HUGGING_FACE_HUB_TOKEN=your_token_here
```