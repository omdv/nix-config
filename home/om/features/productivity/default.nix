{ pkgs, pkgs-unstable, ... }: {
  imports = [
    ./cursor.nix
    ./k9s.nix
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
    ./vscode.nix
  ];

  home.packages = [
    pkgs.beancount # ledger alternative
    pkgs.bruno # api tool
    pkgs.pgcli # great postgres cli from Ukraine
    pkgs.visidata # cli for data analysis
    pkgs-unstable.claude-code # up-to-date claude code
  ];

}
