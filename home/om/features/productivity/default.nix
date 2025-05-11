{ pkgs, ... }: {
  imports = [
    ./cursor.nix
    ./httpie.nix
    ./devenv.nix
    ./k9s.nix
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    aider-chat # AI coding assistant
    beancount # ledger alternative
    bruno # api tool
    pgcli # great postgres cli from Ukraine
    visidata # cli for data analysis
  ];
}
