{pkgs, ...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./htop.nix
    ./llm.nix
    ./mc.nix
    ./navi.nix
    ./qutebrowser.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./yazi.nix
  ];
  home.packages = with pkgs; [
    # base
    file
    zip
    wget
    feh

    # better utils
    bc # Calculator
    comma # Install and run programs by sticking a , before them
    diff-so-fancy # Better diff
    distrobox # Nice escape hatch, integrates docker images with my environment
    eza # Better ls
    fd # Better find
    jq # A lightweight and flexible command-line JSON processor
    maim # Screenshot tool
    ripgrep # Better grep
    yq-go # yaml processor https://github.com/mikefarah/yq

    # system tools
    duf # TUI disk usage
    iotop # io monitoring
    kmon # TUI kernel manager
    lm_sensors # for `sensors` command
    lsof # list open files
    ltrace # library call monitoring
    ncdu # TUI disk usage
    pciutils # lspci
    strace # system call monitoring
    sysz # fzf for systemd
    usbutils # lsusb
    unzip # zip decompressor

    # network tools
    bandwhich # TUI bandwidth monitor
    dnsutils  # `dig` + `nslookup`
    iftop # network monitoring
    ipcalc  # it is a calculator for the IPv4/v6 addresses
    iperf3 # determine max bandwidth
    httpstat # http request metrics
    ldns # replacement of `dig`, it provide the command `drill`
    mtr # network diagnostic tool
    nethogs # net top tool
    netscanner # tui network scanner
    nmap # A utility for network discovery and security auditing
    socat # replacement of openbsd-netcat
    whois # whois lookup

    # nix -related
    alejandra # Nix formatter
    nh # Nice wrapper for NixOS and HM
    nixd # Nix LSP for zed
    nix-tree # Nix tree
    nix-inspect # Nix inspect
    nix-du # Nix du
    nix-index # Nix index
    nix-melt # Nix melt
    nvd # Nix version diff

    # misc
    tldr # Simplified man
    simplescreenrecorder # record screen
  ];
}
