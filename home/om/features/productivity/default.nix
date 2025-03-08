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
    beancount # ledger alternative
    bruno # api tool
    pgcli # great postgres cli from Ukraine
    visidata # cli for data analysis
  ];
}
