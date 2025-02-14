{ pkgs, ... }: {
  home.packages = with pkgs; [
    mudlet
  ];
}
