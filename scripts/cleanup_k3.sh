#!/run/current-system/sw/bin/bash

# Configuration variables
USER="om"
HOST="192.168.1.98"
PORT="22"

# First, SSH to copy the root-owned file to user's home directory and change ownership
ssh -p "$PORT" "$USER@$HOST" "
  sudo -S systemctl stop k3s || true
  sudo -S systemctl disable k3s || true
  sudo -S rm -f /etc/systemd/system/k3s.service
  sudo -S systemctl daemon-reload
  sudo -S rm -rf /etc/rancher
  sudo -S rm -rf /var/lib/rancher
  sudo -S rm -rf /var/lib/kubelet
  sudo -S rm -rf /var/lib/cni
  sudo -S rm -rf /run/flannel
  sudo -S systemctl stop containerd || true
  sudo -S rm -rf /var/lib/containerd
"

echo "K3s has been cleaned up successfully!"
