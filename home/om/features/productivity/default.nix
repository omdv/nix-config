{ pkgs, ... }: {
  imports = [
    ./asdf.nix
    ./devenv.nix
    ./k8s.nix
    ./mail.nix
    ./vscode.nix
    ./zotero.nix
  ];

  home.packages = with pkgs; [
    visidata
  ];
}
