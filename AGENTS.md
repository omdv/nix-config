# Repository Guidelines

## Project Overview

Personal NixOS + home-manager configuration managed as a Nix flake. Targets two machines: `framework` (laptop, i3wm desktop) and `homelab` (headless server). All system and user configuration is declarative; secrets are encrypted with sops-nix/age and committed to the repo.

---

## Architecture & Data Flow

```
flake.nix
├── inputs          — nixpkgs 25.11, nixpkgs-unstable, home-manager, sops-nix,
│                     nixos-hardware, nix-colors, nixvim, firefox-addons
├── overlays/       — three overlays applied to pkgs: flake-inputs, unstable, additions
├── lib/
│   ├── mkHost.nix  — wraps lib.nixosSystem; loads hosts/<name>/
│   ├── mkHome.nix  — wraps lib.homeManagerConfiguration; loads home/<name>/<host>.nix
│   └── mkSecret.nix— produces a sops.secrets entry (owner=om, mode=0400, /run/user-secrets/<name>)
├── hosts/          — NixOS system configs
├── home/           — home-manager user configs
├── modules/        — custom NixOS + HM modules exported as flake outputs
└── pkgs/           — custom package derivations exposed as flake packages
```

**Overlay precedence** (applied in order): `flake-inputs` → `unstable` → `additions` → `modifications` (empty). The `unstable` overlay exposes `pkgs.unstable.*`; the `additions` overlay exposes custom packages from `pkgs/` directly as `pkgs.<name>`.

**home-manager** is used standalone (not as a NixOS module). `mkHome` hard-codes `x86_64-linux`; per-user `nixpkgs.nix` applies all flake overlays.

---

## Key Directories

| Path | Purpose |
|---|---|
| `flake.nix` | Entry point; all inputs, factory wiring, outputs |
| `lib/` | `mkHost`, `mkHome`, `mkSecret` factory functions |
| `hosts/<name>/` | NixOS system config per machine (hardware, boot, sops, optional modules) |
| `hosts/common/global/` | NixOS modules applied to every host (locale, nix, openssh, sops, fish, nix-ld, nix-index) |
| `hosts/common/optional/` | Optional NixOS modules selected per host (i3wm, pipewire, k3s, libvirt, steam, etc.) |
| `home/om/` | Home-manager config for user `om` |
| `home/om/global/` | Base HM config (git, kitty, fonts); always imported |
| `home/om/features/` | Feature bundles: `cli/`, `desktop/`, `nixvim/`, `productivity/`, `pass/`, `gaming/`, `optional/` |
| `modules/nixos/` | Custom NixOS modules (`smartd.nix`) exported as `nixosModules` |
| `modules/home-manager/` | Custom HM modules (`fonts`, `i3scaling`, `monitors`, `wallpaper`) exported as `homeManagerModules` |
| `overlays/` | Nixpkgs overlay definitions |
| `pkgs/` | Custom package derivations (`oh-my-pi`, `pi-coding-agent`, `rustledger`) |
| `scripts/` | Ad-hoc shell scripts (k3s management, homelab ops) |

---

## Development Commands

```bash
# Enter dev shell (provides git, pre-commit, detect-secrets)
nix develop

# Rebuild NixOS system (run on the target machine)
sudo nixos-rebuild switch --flake .#framework
sudo nixos-rebuild switch --flake .#homelab

# Apply home-manager config (standalone, run as user)
home-manager switch --flake .#om@framework
home-manager switch --flake .#om@homelab

# Build a custom package
nix build .#oh-my-pi
nix build .#rustledger
nix build .#pi-coding-agent

# Format Nix files (alejandra)
nix fmt

# Update all flake inputs
nix flake update

# Update a single input
nix flake update nixpkgs

# Encrypt/edit a secrets file
sops home/om/secrets.yaml
sops hosts/framework/secrets.yaml
```

---

## Code Conventions & Common Patterns

### Module structure

Every feature module is a function `{ pkgs, config, lib, inputs, outputs, ... }: { ... }`. The `imports` list composes sub-modules; `home.packages` adds packages; program-specific config uses `programs.<name>.*`.

```nix
# Typical feature module
{ pkgs, ... }: {
  imports = [ ./sub-feature.nix ];
  home.packages = [ pkgs.some-tool pkgs.unstable.other-tool ];
  programs.some-tool = {
    enable = true;
    settings = { ... };
  };
}
```

### Stable vs. unstable packages

- Stable nixpkgs: `pkgs.<name>` (nixos-25.11)
- Unstable nixpkgs: `pkgs.unstable.<name>` (nixos-unstable via overlay)
- Custom packages: `pkgs.<name>` (via `additions` overlay from `pkgs/`)

### Custom package patterns

Three patterns in use:

1. **Prebuilt binary + patchelf** (`oh-my-pi`): `stdenv.mkDerivation` with `fetchurl`, `dontUnpack = true`, manual `patchelf --set-interpreter` for self-contained binaries (e.g., Bun-compiled). Do NOT use `autoPatchelfHook` for self-contained binaries.

2. **Prebuilt binary + autoPatchelfHook** (`rustledger`): `stdenv.mkDerivation` with `fetchurl` + `autoPatchelfHook` for binaries that do need library resolution.

3. **Shell wrapper** (`pi-coding-agent`): `writeShellScriptBin` that patches `$PATH` and delegates to an external tool.

```nix
# Pattern 1 — self-contained binary
{ stdenv, fetchurl, lib, patchelf }:
stdenv.mkDerivation {
  dontUnpack = true; dontBuild = true; dontPatchELF = true; dontStrip = true;
  installPhase = ''
    install -D -m755 $src $out/bin/omp
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/omp
  '';
}

# Pattern 3 — shell wrapper
{ writeShellScriptBin, nodejs_22 }:
writeShellScriptBin "pi" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @mariozechner/pi-coding-agent "$@"
''
```

### Secrets

- Encrypted with `sops` (age keys), committed as `secrets.yaml` blobs.
- Three secrets files: `hosts/framework/secrets.yaml`, `hosts/homelab/secrets.yaml`, `home/om/secrets.yaml`.
- Each encrypted with the host's age key AND the user `om` age key (see `.sops.yaml`).
- In NixOS configs: reference via `sops.secrets.<name>` with `defaultSopsFile` set.
- In home-manager: `sops.defaultSopsFile = ./secrets.yaml; sops.secrets.<name> = {};`.
- `mkSecret` helper sets `owner=om`, `group=wheel`, `mode=0400`, path at `/run/user-secrets/<name>` (underscores replaced with hyphens).

### Theming

`nix-colors` is injected as `colors` via `extraSpecialArgs` in `mkHome`. Host configs set `colorscheme = colors.colorSchemes.<scheme-name>`. Current scheme: `catppuccin-mocha` on framework, `solarized-dark` on homelab.

### Adding a new custom package

1. Create `pkgs/<name>/default.nix`.
2. Add `<name> = pkgs.callPackage ./<name> { };` to `pkgs/default.nix`.
3. Reference in home-manager as `pkgs.<name>` (available via `additions` overlay).
4. Optionally add to `home/om/features/<feature>/default.nix` under `home.packages`.

### Adding a new host feature (optional NixOS module)

1. Create `hosts/common/optional/<name>.nix`.
2. Import it explicitly in `hosts/<hostname>/default.nix`.

---

## Important Files

| File | Role |
|---|---|
| `flake.nix` | Root: all inputs, overlays wiring, `mkHost`/`mkHome` calls, package outputs |
| `lib/mkHost.nix` | NixOS system factory |
| `lib/mkHome.nix` | home-manager config factory; injects sops-nix, nix-colors |
| `lib/mkSecret.nix` | sops secret entry factory |
| `overlays/default.nix` | Defines `unstable`, `additions`, `flake-inputs` overlays |
| `pkgs/default.nix` | Custom package index (callPackage per entry) |
| `home/om/nixpkgs.nix` | Applies all flake overlays in standalone HM; enables `allowUnfree` |
| `home/om/framework.nix` | Framework laptop home-manager entry; imports all feature groups |
| `home/om/homelab.nix` | Homelab home-manager entry; imports minimal feature set |
| `hosts/framework/default.nix` | Framework NixOS system config (hardware, boot, kernel, sops) |
| `hosts/homelab/default.nix` | Homelab NixOS system config |
| `hosts/common/global/` | NixOS modules applied universally |
| `.sops.yaml` | SOPS creation rules mapping secrets files to age recipients |
| `shell.nix` | Dev shell with `pre-commit` and `detect-secrets` |

---

## Runtime & Tooling

- **Nix**: flakes enabled; requires `nix-command` and `flakes` experimental features.
- **Formatter**: `alejandra` (`nix fmt` at root).
- **Secrets**: `sops` CLI with age keys. Key locations: `~/.config/sops/age/keys.txt` (user), host keys in `/etc/ssh/` via sops-nix.
- **Dev shell**: `nix develop` provides `git`, `pre-commit`, `detect-secrets`.
- **No Makefile** or justfile. All operations are bare `nix` or `nixos-rebuild` / `home-manager` commands.
- **nixpkgs channel**: stable `nixos-25.11`; unstable via separate input.
- **home-manager channel**: `release-25.11` tracking stable nixpkgs.

### Key tools configured in this repo

| Tool | Config location |
|---|---|
| fish (primary shell) | `home/om/features/cli/fish.nix` |
| neovim (nixvim) | `home/om/features/nixvim/` |
| kitty (primary terminal) | `home/om/global/kitty.nix` |
| tmux | `home/om/features/cli/tmux.nix` |
| starship | `home/om/features/cli/starship.nix` |
| i3wm | `home/om/features/desktop/i3wm/` |
| k9s | `home/om/features/productivity/k9s.nix` |

---

## Testing & QA

There is no automated test suite. Validation is by building and activating:

```bash
# Dry-run NixOS rebuild (checks evaluation + build without activating)
sudo nixos-rebuild dry-activate --flake .#framework

# Build without activating (catches build failures)
nixos-rebuild build --flake .#framework

# Check flake evaluation (fast, no build)
nix flake check

# Build a specific package to verify it
nix build .#oh-my-pi
```

Pre-commit hooks are available (`pre-commit` in dev shell); `detect-secrets` is configured to prevent accidental secret commits. Encrypted `secrets.yaml` files are the correct pattern — never commit plaintext secrets.
