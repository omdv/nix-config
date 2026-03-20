## NixOS configuration

Personal NixOS + home-manager configuration as a flake. Two machines: `framework` (laptop) and `homelab` (headless server).

## Structure

```
flake.nix          -- inputs, outputs, wiring
hosts/             -- NixOS system configs per machine
home/om/           -- home-manager config for user om
  global/          -- always loaded (git, kitty, fonts)
  features/        -- opt-in feature bundles
modules/           -- custom NixOS and HM modules
pkgs/              -- custom package derivations
overlays/          -- nixpkgs overlays
lib/               -- mkHost, mkHome, mkSecret helpers
```

## Machines

**framework** -- Framework 13 laptop
- xanmod kernel, systemd-boot
- i3wm, picom, polybar, rofi, dunst
- catppuccin-mocha colorscheme
- pipewire, lightdm
- Mullvad VPN, Tailscale
- libvirt, Steam, Java
- zram swap, btrfs with monthly scrub
- auto-cpufreq, xss-lock + i3lock

**homelab** -- headless server
- k3s, Tailscale
- sops-nix secrets

## Key tools

| Tool | Config |
|---|---|
| shell | fish |
| terminal | kitty + tmux |
| editor | neovim (nixvim) with LSP, treesitter, catppuccin |
| mail | neomutt + mbsync + msmtp |
| browser | Brave |
| passwords | pass |
| backups | restic |

## Commands

```bash
# rebuild system
sudo nixos-rebuild switch --flake .#framework

# apply home-manager
home-manager switch --flake .#om@framework

# format
nix fmt

# edit secrets
sops home/om/secrets.yaml
```

## Secrets

Encrypted with sops + age. Three secret files: `hosts/framework/secrets.yaml`, `hosts/homelab/secrets.yaml`, `home/om/secrets.yaml`. Each encrypted for the host age key and the user age key per `.sops.yaml`.
