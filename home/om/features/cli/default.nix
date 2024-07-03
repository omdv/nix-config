{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./direnv.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./kitty.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them
    distrobox # Nice escape hatch, integrates docker images with my environment

    htop # Better top
    bat # Better cat
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    diffsitter # Better diff

    ncdu # TUI disk usage
    duf # TUI disk usage

    bc # Calculator
    jq # JSON pretty printer and manipulator
    sysz # fzf for systemd

    # nixd # Nix LSP
    # alejandra # Nix formatter
    # nixfmt-rfc-style
    # nvd # Differ
    # nix-diff # Differ, more detailed
    # nix-output-monitor
    # nh # Nice wrapper for NixOS and HM

    # ltex-ls # Spell checking LSP
  ];
}
