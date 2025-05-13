import os
import platform
import requests
import time
import subprocess
import zipfile

# Inputs
#token_civitai = ''
hugging_face_token = os.getenv("HF_TOKEN")

def download_file(url, path, filename, retries=9, timeout=120):
    """
    Download a file from a given URL and save it to the specified path with resume support.
    
    Parameters:
    - url (str): URL of the file to be downloaded.
    - path (str): Directory where the file will be saved.
    - retries (int): Number of retries if the download fails. Default is 3.
    - timeout (int): Timeout for the download request in seconds. Default is 10.
    """
    
    # Create the directory if it doesn't exist
    os.makedirs(path, exist_ok=True)
    
    # Determine the file name from the URL or content disposition
    response = requests.head(url, allow_redirects=True)
    content_disposition = response.headers.get('content-disposition')
    print(f"\nDownloading {filename}!")
    
    # Use os.path.join to create the file path in a platform-independent way
    file_path = os.path.join(path, filename)
    
    downloaded_size = 0
    if os.path.exists(file_path):
        downloaded_size = os.path.getsize(file_path)
    
    headers = {}
    if downloaded_size:
        headers['Range'] = f"bytes={downloaded_size}-"
    
    try:
        response = requests.get(url, headers=headers, stream=True, timeout=timeout)
        response.raise_for_status()
        
        total_size = downloaded_size + int(response.headers.get('content-length', 0))
        
        block_size = 2048576  # 1 MB
        
        with open(file_path, 'ab') as file:
            start_time = time.time()
            for data in response.iter_content(block_size):
                file.write(data)
                
                downloaded_size += len(data)
                elapsed_time = time.time() - start_time
                download_speed = downloaded_size / elapsed_time / 1024  # Speed in KiB/s
                
                # Display download progress and speed
                progress = (downloaded_size / total_size) * 100
                print(f"Downloaded {downloaded_size}/{total_size} bytes "
                      f"({progress:.2f}%) at {download_speed:.2f} KiB/s", end='\r')
        
        print(f"\nDownload completed {filename}!")
        return file_path

    except requests.RequestException as e:
        if retries > 0:
            print(f"Error occurred: {e}. Retrying...")
            return download_file(url, path, retries=retries-1, timeout=timeout)
        else:
            print("Download failed after multiple retries.")
            return None


# Use os.path.join to create the file paths in a platform-independent way
checkpoints_path = os.path.join("ComfyUI", "models", "checkpoints")
loras_path = os.path.join("ComfyUI", "models", "loras")
clip_path = os.path.join("ComfyUI", "models", "clip")
vae_path = os.path.join("ComfyUI", "models", "vae")
controlnet_path = os.path.join("ComfyUI", "models", "controlnet")
upscale_path = os.path.join("ComfyUI", "models", "upscale_models")
face_path_bbox = os.path.join("ComfyUI", "models", "ultralytics", "bbox")
face_path_sams = os.path.join("ComfyUI", "models", "sams")
embeddings_path = os.path.join("ComfyUI", "models", "embeddings")
diff_models_path = os.path.join("ComfyUI", "models", "diffusion_models")

# checkpoints

#download_file('https://civitai.com/api/download/models/1464711?token=' + token_civitai,
 #             checkpoints_path, 'bigLove_xl2.safetensors')


#loras
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/Breast%20Slider%20-%20Pony_alpha1.0_rank4_noxattn_last.safetensors',
              loras_path, 'Breast%20Slider%20-%20Pony_alpha1.0_rank4_noxattn_last.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/Thigh%20Size%20Slider%20V2_alpha1.0_rank4_noxattn_last.safetensors',
              loras_path, 'Thigh%20Size%20Slider%20V2_alpha1.0_rank4_noxattn_last.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/dmd2_sdxl_4step_lora.safetensors',
              loras_path, 'dmd2_sdxl_4step_lora.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/thicc_v1.4-pony_done.safetensors',
              loras_path, 'thicc_v1.4-pony_done.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/tat1-000131.safetensors',
              loras_path, 'tat1-000131.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/Bubble%20Butt_alpha1.0_rank4_noxattn_last.safetensors',
              loras_path, 'Bubble%20Butt_alpha1.0_rank4_noxattn_last.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/chars/vikaface2803-000145.safetensors',
              loras_path, 'vikaface2803-000145.safetensors')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/flux-turbo-alpha-lora.safetensors',
              loras_path, 'flux-turbo-alpha-lora.safetensors')

# controlnet
download_file('https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth',
              controlnet_path, 'depth_anything_v2_vitl.pth')

download_file('https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors',
              controlnet_path, 'controlnet-union-sdxl-1.0.safetensors')
# upscale
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth',
              upscale_path, '4x_NMKD-Superscale-SP_178000_G.pth')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/4x-UltraSharp.pth',
              upscale_path, '4x-UltraSharp.pth')
# face detection and segmentation
download_file('https://huggingface.co/segments-arnaud/sam_vit_h/resolve/main/sam_vit_h_4b8939.pth',
              face_path_sams, 'sam_vit_h_4b8939.pth')
download_file('https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov9c.pt',
              face_path_bbox, 'face_yolov9c.pt')
download_file('https://huggingface.co/kaareej/loras-models/resolve/main/Eyeful_v2-Paired.pt',
              face_path_bbox, 'Eyeful_v2-Paired.pt')

# clip and vae
download_file('https://huggingface.co/OwlMaster/FLUX_LoRA_Train/resolve/main/t5xxl_fp16.safetensors',
              clip_path, 't5xxl_fp16.safetensors')

download_file('https://huggingface.co/OwlMaster/FLUX_LoRA_Train/resolve/main/clip_l.safetensors',
              clip_path, 'clip_l.safetensors')
download_file('https://huggingface.co/OwlMaster/FLUX_LoRA_Train/resolve/main/ae.safetensors',
              vae_path, 'ae.safetensors')

### MODELS WITH HUGGINGFACE ACCESS KEY

### SET TOKEN

# Set the environment variable
os.environ['HUGGING_FACE_HUB_TOKEN'] = hugging_face_token
os.environ['HF_HUB_ENABLE_HF_TRANSFER'] = "1"
os.environ['HF_HUB_VERBOSITY'] = "debug"


# Determine the operating system
system = platform.system()

if system == "Linux":
    export_command = f'export HUGGING_FACE_HUB_TOKEN={hugging_face_token}'
    subprocess.run(export_command, shell=True, check=True)
    export_command = f'export HF_HUB_ENABLE_HF_TRANSFER=1'
    subprocess.run(export_command, shell=True, check=True)   
    export_command = f'export HF_HUB_VERBOSITY="debug"'
    subprocess.run(export_command, shell=True, check=True)      
elif system == "Windows":
    set_command = f'set HUGGING_FACE_HUB_TOKEN={hugging_face_token}'
    subprocess.run(set_command, shell=True, check=True)
    export_command = f'set HF_HUB_ENABLE_HF_TRANSFER=1'
    subprocess.run(export_command, shell=True, check=True)   
    export_command = f'set HF_HUB_VERBOSITY="debug"'
    subprocess.run(export_command, shell=True, check=True) 

# Command to log in using the token
login_command = ['huggingface-cli', 'login', '--token', hugging_face_token]

# Execute the login command and capture output
try:
    result = subprocess.run(login_command, check=True, capture_output=True, text=True)
    print("Output:", result.stdout)
    print("Error:", result.stderr)
except subprocess.CalledProcessError as e:
    print("Command failed with exit code:", e.returncode)
    print("Output:", e.output)
    print("Error:", e.stderr)


### Download
from huggingface_hub import snapshot_download

### LORAS
# Define the repository, file path, and local directory
repo_id_set = "vasss344444444/blondeasian1"
local_dir_set = loras_path


# Ensure the local directory exists
os.makedirs(local_dir_set, exist_ok=True)
print(".\n.\nDOWNLOAD Started...")
snapshot_download(
            repo_id=repo_id_set,
            allow_patterns=["blondeasian-flux-v2-000134.safetensors","blondeasian-bodylora-biglovexl2-v2-rank128.safetensors", "blondeasian-bodylora-biglovexl2-v2-000113.safetensors","blondeasian-facev3.safetensors", "blondeasian-flux.safetensors"],
            local_dir=local_dir_set,
        )

print(".\n.\nDOWNLOAD LORAS COMPLETED")

## DOWNLOAD checkpoint MODELS
local_dir_set = checkpoints_path


# Ensure the local directory exists
os.makedirs(local_dir_set, exist_ok=True)
print(".\n.\nDOWNLOAD Started...")
snapshot_download(
            repo_id=repo_id_set,
            allow_patterns=["bigLove_xl2.safetensors"],
            local_dir=local_dir_set,
        )


print(".\n.\nDOWNLOAD checkpoint models COMPLETED")

# DOWNLOAD DIFF MODELS
repo_id_set = "black-forest-labs/FLUX.1-dev"
local_dir_set = diff_models_path


# Ensure the local directory exists
os.makedirs(local_dir_set, exist_ok=True)
print(".\n.\nDOWNLOAD Started...")
snapshot_download(
            repo_id=repo_id_set,
            allow_patterns=["flux1-dev.safetensors"],
            local_dir=local_dir_set,
        )


print(".\n.\nDOWNLOAD diffusion models COMPLETED")
