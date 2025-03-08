{ pkgs, ... }: {
  home.packages = with pkgs; [
    pyradio
  ];
}
