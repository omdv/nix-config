{pkgs, ...}: {
  imports = [
    ./asdf.nix
    ./devenv.nix
    ./k8s.nix
    ./mail.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    visidata
  ];
}
