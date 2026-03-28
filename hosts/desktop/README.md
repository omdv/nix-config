# Desktop Host Configuration

Basic headless NixOS configuration for the desktop host.

## Setup Steps

### 1. Copy hardware-configuration.nix

Copy the generated `hardware-configuration.nix` from your desktop machine:

```bash
# On the desktop machine after initial NixOS install:
nixos-generate-config --show-hardware-config > hardware-configuration.nix
# Copy this file to hosts/desktop/hardware-configuration.nix in this repo
```

### 2. Update networking.nix

Update the `hostId` in `networking.nix`:

```bash
# On the desktop machine:
head -c 8 /etc/machine-id
# Replace the "00000000" placeholder in networking.nix with the output
```

### 3. Generate and configure age key for sops

```bash
# On the desktop machine after first boot:
# The host SSH key will be automatically converted to age format
# Get the age public key:
nix-shell -p ssh-to-age --run 'ssh-keyscan localhost | ssh-to-age'

# Or from the SSH host key:
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

Then update `.sops.yaml` in this repo:

- Replace `age1PLACEHOLDER_REPLACE_WITH_DESKTOP_AGE_KEY` with the actual age public key

### 4. Create secrets file

```bash
# Create the secrets file with required secrets:
sops hosts/desktop/secrets.yaml
```

Add the following secret:

```yaml
ntfy_system_topic: <your-ntfy-topic-url>
```

### 5. Build and deploy

```bash
# Build the configuration (from this repo):
nix build .#nixosConfigurations.desktop.config.system.build.toplevel

# Deploy to the machine:
sudo nixos-rebuild switch --flake .#desktop

# Apply home-manager configuration:
home-manager switch --flake .#om@desktop
```

## Configuration Overview

- **Type**: Headless server (no GUI)
- **Base features**: Common global config, fish shell, openssh, nix-ld, nix-index
- **Services**: tailscale, smartd, system-notifications
- **User**: om (with sudo access)
- **Filesystem**: Uses DHCP networking by default
- **State version**: 25.11

## Adding Features

To add optional features, import them in `default.nix`:

```nix
  imports = [
    # ... existing imports ...
    ../common/optional/k3s.nix         # Kubernetes
    ../common/optional/virtualisation.nix  # Docker/Podman
    ../common/optional/zfs-base.nix    # ZFS support
    # etc.
  ];
```

Available optional modules are in `hosts/common/optional/`.
