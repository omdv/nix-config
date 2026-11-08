{pkgs, ...}: {
  imports = [
    ./zed.nix
  ];

  home.packages = [
    pkgs.bruno
    pkgs.unstable.code-cursor
  ];
}
