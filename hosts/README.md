# NixOS Host Configurations

This directory contains NixOS system configurations for all machines in the fleet.

## Structure

```text
hosts/
├── framework/              # Framework laptop (primary workstation)
│   ├── default.nix        # System config entry point
│   ├── hardware-configuration.nix
│   ├── networking.nix
│   └── secrets.yaml       # SOPS-encrypted host secrets
├── homelab/               # Homelab server (headless)
│   ├── default.nix
│   ├── hardware-configuration.nix
│   ├── networking.nix
│   └── secrets.yaml
└── common/                # Shared configuration
    ├── global/            # Applied to ALL hosts
    ├── optional/          # Opt-in features per host
    └── users/             # User account definitions
```

## Hosts

### `framework` - Primary Workstation

**Hardware:** Framework Laptop 13 (AMD)
**Role:** Daily driver with full desktop environment
**Features:**

- i3wm desktop environment
- PipeWire audio
- Full development toolchain
- Gaming support (Steam)
- Backup automation

**Build:**

```bash
sudo nixos-rebuild switch --flake .#framework
```

### `homelab` - Server

**Hardware:** Custom server
**Role:** Self-hosted services and K3s cluster
**Features:**

- Headless (no GUI)
- K3s Kubernetes cluster
- Samba file sharing
- ZFS storage
- Automated backups

**Build:**

```bash
sudo nixos-rebuild switch --flake .#homelab
```

## Common Configuration

### `common/global/`

Modules applied to **every host** automatically:

- `boot.nix` - Boot loader and kernel configuration
- `fish.nix` - Fish shell as default
- `locale.nix` - Timezone, i18n, keyboard layout
- `nix.nix` - Nix daemon settings, flakes, overlays
- `openssh.nix` - SSH server configuration
- `sops.nix` - SOPS secrets integration
- `nix-ld.nix` - Dynamic linking for non-NixOS binaries
- `nix-index.nix` - Command-not-found integration

### `common/optional/`

Opt-in modules imported explicitly by hosts:

- `awesomewm.nix` - AwesomeWM window manager (removed)
- `btrfs.nix` - Btrfs filesystem utilities
- `gnome.nix` - GNOME desktop environment
- `hyprland.nix` - Hyprland compositor
- `i3wm.nix` - i3 window manager + X11
- `k3s.nix` - K3s Kubernetes cluster
- `libvirt.nix` - QEMU/KVM virtualization
- `pipewire.nix` - PipeWire audio server
- `smartd.nix` - S.M.A.R.T. disk monitoring
- `steam.nix` - Steam gaming platform
- `vpn.nix` - WireGuard VPN client
- `zfs.nix` - ZFS filesystem support
- And more...

### `common/users/`

User account definitions (currently just `om`):

- Shell, groups, sudo access
- Consistent UID/GID across hosts

## Adding a New Host

1. **Create host directory:**

   ```bash
   mkdir hosts/newhost
   ```

2. **Generate hardware config:**

   ```bash
   nixos-generate-config --root /mnt --dir hosts/newhost
   ```

3. **Create `default.nix`:**

   ```nix
   {
     imports = [
       ./hardware-configuration.nix
       ./networking.nix
       ../common/global
       ../common/users/om.nix

       # Optional features
       ../common/optional/i3wm.nix
     ];

     networking.hostName = "newhost";
     system.stateVersion = "25.11";
   }
   ```

4. **Add to `flake.nix`:**

   ```nix
   nixosConfigurations.newhost = mkHost "newhost";
   ```

5. **Set up secrets:**

   ```bash
   # Generate age key for host
   ssh-keyscan newhost | ssh-to-age > /tmp/newhost.age

   # Add to .sops.yaml
   # Create hosts/newhost/secrets.yaml
   ```

## Secrets Management

Each host has its own `secrets.yaml` encrypted with SOPS + age:

- **Host keys:** SSH host keys converted to age
- **User keys:** `~/.config/sops/age/keys.txt`
- **Access:** Secrets decrypted at boot to `/run/user-secrets/`

See `.sops.yaml` for encryption rules.

## Best Practices

- **Global config:** Put universally needed config in `common/global/`
- **Optional features:** Keep opt-in modules in `common/optional/`
- **Hardware-specific:** Keep in host-specific directory
- **Secrets:** Always use SOPS, never commit plaintext
- **Testing:** Test builds with `nixos-rebuild build --flake .#hostname` before deploying

## Related Documentation

- [Home Manager Configuration](../home/om/features/README.md)
- [Custom Packages](../pkgs/README.md)
- [Repository Guidelines](../AGENTS.md)
