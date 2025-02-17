{ pkgs, ... }: {
  home.packages = with pkgs; [
    vcmi
  ];
}
