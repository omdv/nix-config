{pkgs, ...}: {
  imports = [
    ./vscode.nix
    ./zed.nix
  ];

  home.packages = [
    pkgs.bruno
    pkgs.unstable.code-cursor
  ];
}
