{pkgs, ...}: let
  opencodeTui = {
    "$schema" = "https://opencode.ai/tui.json";
    theme = "catppuccin";
  };
in {
  home.packages = [
    pkgs.unstable.opencode
  ];

  xdg.configFile."opencode/tui.json".text = builtins.toJSON opencodeTui;
}
