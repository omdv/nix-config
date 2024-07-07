{pkgs, ...}: {
  imports = [
    ./asdf.nix
    ./devenv.nix
    ./k8s.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    visidata
  ];
}
