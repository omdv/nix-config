{pkgs, ...}: {
  imports = [
    ./k9s.nix
    ./pi
    ./zed.nix
  ];

  home.packages = [
    pkgs.bruno # api tool
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # tui for data analysis

    # AI tools
    pkgs.unstable.aichat
    pkgs.pi-coding-agent # pi wrapper with nodejs
  ];
}
