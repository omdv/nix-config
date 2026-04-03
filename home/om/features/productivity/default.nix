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
    pkgs.unstable.devenv # dev environment manager
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # cli for data analysis

    pkgs.unstable.antigravity # google antigravity
    pkgs.claude-code # up-to-date claude code
    pkgs.unstable.claude-monitor # up-to-date claude cost monitor

    # AI tools
    pkgs.unstable.aichat
    pkgs.pi-coding-agent # pi wrapper with nodejs

    # miscellaneous
    pkgs.rustledger # rust ledger (binary)
    pkgs.sc-im
  ];
}
