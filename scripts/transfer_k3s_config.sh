#!/run/current-system/sw/bin/bash

# Configuration variables
HOMELAB_USER="om"
HOMELAB_HOST="192.168.1.98"
REMOTE_CONFIG_PATH="/etc/rancher/k3s/k3s.yaml"
LOCAL_CONFIG_DIR="$HOME/.kube"
LOCAL_CONFIG_PATH="$LOCAL_CONFIG_DIR/config"

# First, SSH to copy the root-owned file to user's home directory and change ownership
ssh "$HOMELAB_USER@$HOMELAB_HOST" "
    mkdir -p $LOCAL_CONFIG_DIR &&
    sudo -S cp $REMOTE_CONFIG_PATH $LOCAL_CONFIG_PATH &&
    sudo -S chown $HOMELAB_USER $LOCAL_CONFIG_PATH
"

# Ensure local .kube directory exists
mkdir -p "$LOCAL_CONFIG_DIR"

# Copy k3s config from remote host and replace localhost with actual IP
scp "$HOMELAB_USER@$HOMELAB_HOST:$LOCAL_CONFIG_PATH" "$LOCAL_CONFIG_PATH.tmp"

# Replace localhost with actual IP address
sed "s/127.0.0.1/$HOMELAB_HOST/g" "$LOCAL_CONFIG_PATH.tmp" > "$LOCAL_CONFIG_PATH"

# Clean up temporary file
rm "$LOCAL_CONFIG_PATH.tmp"

# Set proper permissions
chmod 600 "$LOCAL_CONFIG_PATH"

echo "K3s config has been transferred and configured successfully!"
