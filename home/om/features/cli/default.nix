{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./mc.nix
    ./nnn.nix
    ./network-tui.nix
    ./qutebrowser.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them
    distrobox # Nice escape hatch, integrates docker images with my environment

    file # base
    zip # base
    wget # base

    htop # Better top
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    diff-so-fancy # Better diff

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
