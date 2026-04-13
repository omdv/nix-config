# Home Manager Features

This directory contains modular home-manager configurations organized by functionality.

## Organization

Features are grouped into **bundles** that can be imported together or individually:

```text
features/
├── cli/              # Command-line tools and shell configuration
├── desktop/          # Desktop environment configurations
│   ├── common/       # Shared desktop apps (browser, cursor, etc.)
│   ├── gnome/        # GNOME-specific config
│   └── i3wm/         # i3 window manager config
├── gaming/           # Games and gaming platforms
├── nixvim/           # Neovim via nixvim
├── optional/         # Single-file opt-in features
├── pass/             # Password manager (pass/gopass)
└── productivity/     # Development and productivity tools
```

## Feature Bundles

### `cli/` - Command-Line Interface

**Import:** `./features/cli`

Core shell experience and CLI tools. Includes:

- **Shell:** Fish with starship prompt
- **Multiplexer:** zellij
- **Editor:** (config only, neovim is in nixvim)
- **File tools:** bat, eza, fd, ripgrep, fzf, yazi
- **System tools:** btop, htop, ncdu, duf
- **Network tools:** bandwhich, mtr, nmap, httpstat
- **Dev tools:** git, direnv, ssh, gpg
- **Nix tools:** alejandra, nh, nixd, nix-tree, nvd

**Sub-modules:** 16 files (atuin, bat, fish, git, gpg, ssh, zellij, etc.)

### `desktop/common/` - Shared Desktop Applications

**Import:** `./features/desktop/common`

Applications used across all desktop environments:

- **Browsers:** Firefox (with extensions), Brave
- **Theme:** GTK themes, cursor themes
- **System:** XDG config, keyring integration, pavucontrol

**Sub-modules:** 8 files

### `desktop/i3wm/` - i3 Window Manager

**Import:** `./features/desktop/i3wm`

Full i3 desktop environment:

- **WM:** i3 configuration with custom keybindings
- **Bar:** Polybar with system info
- **Compositor:** Picom for transparency
- **Notifications:** Dunst
- **Launcher:** Rofi (shared with other WMs)

**Sub-modules:** 5 files (keybindings, picom, polybar, dunst, + rofi from common)

### `desktop/gnome/` - GNOME Desktop

**Import:** `./features/desktop/gnome`

Minimal GNOME configuration:

- Scaling settings via dconf
- Wallpaper integration

**Files:** 1 standalone config

### `gaming/` - Gaming

**Import:** `./features/gaming`

Game installations (uses unstable channel):

- Cataclysm DDA
- OpenTTD
- OpenRCT2

**Files:** 1 standalone config

### `nixvim/` - Neovim Configuration

**Import:** `./features/nixvim`

Full Neovim setup via nixvim:

- **LSP:** Multiple language servers configured
- **Completion:** nvim-cmp with multiple sources
- **UI:** bufferline, lualine, nvim-tree, which-key
- **Git:** gitsigns integration
- **Formatting:** conform.nvim with multiple formatters
- **Syntax:** Treesitter for 30+ languages

**Sub-modules:** 14 files + statusline directory

### `pass/` - Password Management

**Import:** `./features/pass`

Password store configuration:

- `pass` with OTP extension
- `gopass` alternative

**Files:** 1 standalone config

### `productivity/` - Development & Productivity

**Import:** `./features/productivity`

Development tools and productivity apps:

- **Editors:** VSCode, Cursor, Zed
- **Tools:** k9s (Kubernetes), khard (contacts), neomutt (mail)
- **Email:** mbsync + IMAP configuration
- **Extensions:** oh-my-pi, pi coding agent

**Sub-modules:** 7 files + 2 extension directories

### `optional/` - Standalone Optional Features

**Import:** Individual files as needed

Single-purpose tools imported selectively:

- `discord.nix` - Discord client
- `mpv.nix` - Media player
- `telegram.nix` - Telegram
- `torrent.nix` - Transmission BitTorrent
- `zathura.nix` - PDF viewer
- `zotero.nix` - Reference manager
- And more (13 total)

**Pattern:** No `default.nix` - import directly in `framework.nix`

## Import Patterns

### Bundle Import (Aggregated)

Feature bundles with multiple sub-modules use a `default.nix` aggregator:

```nix
# In home/om/framework.nix
imports = [
  ./features/cli             # Imports cli/default.nix
  ./features/desktop/common  # Imports desktop/common/default.nix
  ./features/nixvim          # Imports nixvim/default.nix
];
```

The `default.nix` handles importing all sub-modules:

```nix
# In features/cli/default.nix
{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./fish.nix
    # ... all sub-modules
  ];
  home.packages = [ /* shared packages */ ];
}
```

### Individual Import (Optional)

Standalone features are imported directly:

```nix
# In home/om/framework.nix
imports = [
  ./features/optional/discord.nix
  ./features/optional/telegram.nix
];
```

## Adding a New Feature

### As a Standalone Module

1. Create `features/optional/newtool.nix`:

   ```nix
   {pkgs, ...}: {
     home.packages = [pkgs.newtool];

     programs.newtool = {
       enable = true;
       settings = { ... };
     };
   }
   ```

2. Import in `home/om/framework.nix`:

   ```nix
   imports = [
     ./features/optional/newtool.nix
   ];
   ```

### As Part of a Bundle

1. Create `features/cli/newtool.nix`:

   ```nix
   {pkgs, ...}: {
     programs.newtool.enable = true;
   }
   ```

2. Add to `features/cli/default.nix`:

   ```nix
   imports = [
     ./newtool.nix
     # ... existing imports
   ];
   ```

### As a New Bundle

1. Create directory with sub-modules:

   ```bash
   mkdir features/newbundle
   # Create sub-modules
   ```

2. Create aggregator `features/newbundle/default.nix`:

   ```nix
   {pkgs, ...}: {
     imports = [
       ./mod1.nix
       ./mod2.nix
     ];
   }
   ```

3. Import in `home/om/framework.nix`:

   ```nix
   imports = [
     ./features/newbundle
   ];
   ```

## Configuration Patterns

### Program Configuration

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "email@example.com";
  extraConfig = { ... };
};
```

### Service Configuration

```nix
services.dunst = {
  enable = true;
  settings = {
    global = { ... };
  };
};
```

### File Management

```nix
home.file.".config/app/config.toml".text = ''
  key = "value"
'';

xdg.configFile."app/config.toml".source = ./config.toml;
```

### Package Installation

```nix
home.packages = with pkgs; [
  tool1
  tool2
  unstable.tool3  # From unstable channel
];
```

## Best Practices

- **Modularity:** One concern per file
- **Aggregators:** Use `default.nix` for bundles with 3+ sub-modules
- **Imports first:** Always place `imports = [...]` at the top of the attrset
- **Comments:** Document non-obvious configuration
- **Stable vs. Unstable:** Prefer stable, use `pkgs.unstable.*` when needed
- **Testing:** Test with `home-manager build --flake .#om@framework`

## Per-Host Configuration

Different hosts can import different features:

```nix
# home/om/framework.nix (full desktop)
imports = [
  ./features/cli
  ./features/desktop/i3wm
  ./features/gaming
  ./features/nixvim
  ./features/productivity
];

# home/om/homelab.nix (minimal server)
imports = [
  ./features/cli
  ./features/productivity  # Just for k9s, mail
];
```

## Related Documentation

- [NixOS Host Configuration](../../hosts/README.md)
- [Custom Packages](../../pkgs/README.md)
- [Repository Guidelines](../../AGENTS.md)
