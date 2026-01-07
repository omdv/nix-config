{ pkgs, pkgs-unstable, ... }: {
  imports = [
    ./cloud.nix
    ./cursor.nix
    ./k9s.nix
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
    ./vscode.nix
    ./zed.nix
  ];

  home.packages = [
    pkgs.beancount # ledger alternative
    pkgs.bruno # api tool
    pkgs.unstable.devenv # dev environment manager
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # cli for data analysis
    pkgs-unstable.claude-code # up-to-date claude code
    pkgs-unstable.claude-monitor # up-to-date claude cost monitor
  ];
}
