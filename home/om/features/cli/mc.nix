{ pkgs, ...}: {
  home.packages = with pkgs; [
    mc
  ];
}
