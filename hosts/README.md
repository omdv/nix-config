# NixOS Host Configurations

This directory contains NixOS system configurations for all machines in the fleet.

## Structure

```text
hosts/
├── emulator/              # Disposable aarch64 Unkernel guest with integrated HM
│   ├── default.nix        # Machine identity, user and Home Manager wiring
│   ├── unkernel.nix       # Boot compatibility and guest runtime services
│   └── index.html         # Visitor-side launcher and terminal UI
├── framework/              # Framework laptop (primary workstation)
│   ├── default.nix        # System config entry point
│   ├── hardware-configuration.nix
│   ├── networking.nix
│   ├── tl-wn722n.nix       # TL-WN722N v1 monitor/injection support
│   └── secrets.yaml       # SOPS-encrypted host secrets
├── homelab/               # Homelab server (headless)
│   ├── default.nix
│   ├── hardware-configuration.nix
│   ├── networking.nix
│   └── secrets.yaml
└── common/                # Shared configuration
    ├── global/            # Shared by the native hosts
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
- TP-Link TL-WN722N v1 monitor-mode and packet-injection support
- Backup automation

**Build:**

```bash
sudo nixos-rebuild switch --flake .#framework
```

#### TL-WN722N v1

`framework/tl-wn722n.nix` supports the Atheros AR9271 revision (`0cf3:9271`).
It loads `ath9k_htc`, enables redistributable firmware, reserves the adapter's
permanent MAC address from NetworkManager, and installs `aircrack-ng`, `iw`,
and `usbutils`.

Use `iw dev` to find the adapter interface, then create a monitor interface:

```bash
sudo airmon-ng start <interface>
```

Run injection tests only against networks you are authorized to test:

```bash
sudo aireplay-ng --test <monitor-interface>
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

### `emulator` - Disposable Browser Guest

`emulator/default.nix` selects the aarch64 system, declares the user and integrates
Home Manager through the upstream NixOS module. It imports `emulator/unkernel.nix`
for boot compatibility, store registration and terminal transport.
`../home/om/emulator.nix` selects the user environment; there is no separate
`om@emulator` standalone Home Manager output.

`emulator/index.html` is the frontend, not a NixOS module. Packaging publishes it
beside the runtime and image. In the visitor's browser it boots Unkernel, waits
for guest readiness, connects the interactive terminal, and exposes restart
and diagnostic controls; it does not define the guest's packages or dotfiles.

Boot diagnostics are plain text: guest-console colour/control sequences and OSC
metadata are filtered across output chunk boundaries. Ordinary messages remain
visible. The interactive terminal still uses xterm's full colour/control handling.

The interactive terminal hides its scrollbar so it cannot cover the right prompt.
Wheel/trackpad scrollback remains enabled; page and boot-log scrollbars are unchanged.
A separate, padding-free sizing container keeps terminal cells inside the frame on
resize. The status line disappears once ready; boot progress and errors remain visible.

Unkernel supplies the kernel and initial mounts. The guest has no network,
personal secrets, or persistent disk. Its systemd services require successful
Home Manager activation before opening the `om` terminal.

The pinned runtime is `unkernel@0.2.0-261124-c08e977`. Before the rename,
real NixOS stage-2 activation, systemd 260.5, integrated Home Manager activation
and an `om` shell were observed under Node and Chromium 157. The renamed guest
has not been rebuilt or boot-tested; it remains experimental, not a native-kernel
VM or a security boundary for hostile code.

The bootstrap supplies `/dev/fd` and standard-stream links normally created by
NixOS stage 1. `register-nix-paths.service` seeds the ephemeral Nix database and
system profile before HM runs. The kernel's own ASLR defaults are retained:
NixOS's stock-ARM entropy file requested 33 bits, while Unkernel's observed
default is 18. Other systemd failures are not ignored.

`hvc0` is a boot log, not a second unattended Fish login. The Unkernel vsock
terminal service requires successful HM activation; the page checks guest and
home identity before opening its only interactive login through a PTY.

Build the complete emulator bundle, including its root image, without activating a native host:

```bash
nix build --no-link path:.#packages.aarch64-linux.emulator
```

The pre-rename image was **3,123,822,592 bytes (2.91 GiB)**. It carries the full selected
closure, but the browser reads it using HTTP ranges instead of requiring a
single multi-gigabyte download before boot. Image size is not browser RAM usage.
Builds require an ARM builder or configured aarch64 emulation on x86.

Measured before the rename with the shared smoke on the local x86 workstation, native Chromium
157 with software rendering, a 2 GiB single-CPU guest and the local range server:

| Scenario | Time to verified interactive readiness |
|---|---:|
| Fresh browser profile / first boot | 56.9 seconds |
| Fresh guest restart in the same page | 57.7 seconds |

These are pre-rename local observations, not new measurements or hosted-performance guarantees. Restart is
not snapshot resume: NixOS/HM activation, including bat cache generation, runs
again. The smoke also saved a file through configured Nixvim, verified terminal
resize/control input, confirmed that the scratch file disappeared and the
managed Starship configuration returned after restart, and rejected a failed
image request without offering a shell.

The host does not import `common/global`, which owns native boot and
secret-management assumptions. Framework and Homelab retain standalone Home
Manager. See the [root README](../README.md#emulator-guest) for the static launcher,
manual browser verification and deployment prerequisites.

`mkHost` takes an explicit module path. All three hosts pass their directories:
`./hosts/framework`, `./hosts/homelab` and `./hosts/emulator`.

## Common Configuration

### `common/global/`

Modules explicitly imported by the native hosts:

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
   nixosConfigurations.newhost = mkHost ./hosts/newhost;
   ```

5. **Set up secrets:**

   ```bash
   # Generate age key for host
   ssh-keyscan newhost | ssh-to-age > /tmp/newhost.age

   # Add to .sops.yaml
   # Create hosts/newhost/secrets.yaml
   ```

## Secrets Management

Each native host has its own `secrets.yaml` encrypted with SOPS + age:

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
