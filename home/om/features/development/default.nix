{pkgs, ...}: {
  imports = [
    ./k9s.nix
    ./zed.nix
  ];

  home.packages = [
    pkgs.bruno # api tool
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # tui for data analysis

    # Development tools
    pkgs.unstable.code-cursor
    pkgs.unstable.aichat
    pkgs.oh-my-pi # oh-my-pi binary package with interpreter patching
    pkgs.openspec # openspec helper
  ];
}
