{ pkgs, ... }: {
  imports = [
    ./devenv.nix
    ./k8s.nix
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
    ./vscode.nix
    ./zotero.nix
  ];

  home.packages = with pkgs; [
    visidata
    nil #lsp
  ];
}
