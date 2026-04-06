{pkgs, ...}: {
  imports = [
    ./k9s.nix
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
    ./pi
    ./zed.nix
  ];

  home.packages = [
    pkgs.unstable.awscli2 # aws cloud cli
    pkgs.beancount # ledger alternative
    pkgs.bruno # api tool
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # cli for data analysis

    # AI tools
    pkgs.unstable.aichat
    pkgs.pi-coding-agent # pi wrapper with nodejs

    # miscellaneous
    pkgs.sc-im
  ];
}
