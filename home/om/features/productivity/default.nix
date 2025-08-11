{ pkgs, ... }: {
  imports = [
    ./cursor.nix
    ./k9s.nix
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    claude-code # up-to-date claude code
    beancount # ledger alternative
    bruno # api tool
    pgcli # great postgres cli from Ukraine
    visidata # cli for data analysis
  ];
}
