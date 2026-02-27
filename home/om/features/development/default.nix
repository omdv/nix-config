{pkgs, ...}: {
  imports = [
    ./k9s.nix
    ./pi
    ./mirage-proxy.nix
    ./zed.nix
  ];

  home.packages = [
    pkgs.bruno # api tool
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # tui for data analysis

    # Development tools
    pkgs.unstable.code-cursor
    pkgs.unstable.aichat
    pkgs.pi-coding-agent # pi wrapper with nodejs
    pkgs.oh-my-pi # oh-my-pi binary package with interpreter patching
    pkgs.dirac # dirac wrapper with nodejs
    pkgs.mirage-proxy
    pkgs.openspec # openspec helper
  ];
}
