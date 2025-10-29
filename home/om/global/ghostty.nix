{ pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    ghostty
  ];
}
