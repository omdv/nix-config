{ pkgs, ... }: {
  home.packages = with pkgs; [
    bsdgames
  ];
}
