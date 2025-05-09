#!/bin/bash

MAX_RETRIES=3
RETRY_WAIT=5
PORT=8188

# Install required packages
echo "Installing required packages..."
sudo apt-get update -qq
sudo apt-get install -y curl grep coreutils

# Install the latest cloudflared
echo "Installing the latest cloudflared..."
TMP_BIN="cloudflared"
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o $TMP_BIN
sudo install $TMP_BIN /usr/local/bin/cloudflared
rm -f $TMP_BIN

# Retry loop
for attempt in $(seq 1 $MAX_RETRIES); do
    echo "🔁 Starting Cloudflare Tunnel (Attempt $attempt of $MAX_RETRIES)..."
    
    # Live logs + extract URL line once
    cloudflared tunnel --url http://localhost:$PORT --protocol http2 2>&1 | tee /tmp/cloudflared.log | while IFS= read -r line; do
        echo "$line"
        if echo "$line" | grep -q 'https://.*\.trycloudflare\.com'; then
            url=$(echo "$line" | grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com')
            echo "✅ Public URL: $url"
        fi
    done

    # Check if URL was printed
    if grep -q 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' /tmp/cloudflared.log; then
        exit 0
    fi

    echo "❌ Tunnel failed to produce URL. Retrying in $RETRY_WAIT seconds..."
    sleep $RETRY_WAIT
done

echo "❌ Tunnel failed after $MAX_RETRIES attempts."
exit 1