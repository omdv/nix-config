{pkgs, ...}: let
  opencodeTui = {
    "$schema" = "https://opencode.ai/tui.json";
    theme = "catppuccin";
  };

  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    plugin = ["opencode-openai-codex-auth"];
    mcp.context-mode = {
      type = "local";
      command = ["${pkgs.context-mode}/bin/context-mode"];
    };
  };
in {
  home.packages = [
    pkgs.context-mode
    pkgs.unstable.opencode
  ];

  xdg.configFile = {
    "opencode/tui.json".text = builtins.toJSON opencodeTui;
    "opencode/opencode.json".text = builtins.toJSON opencodeConfig;
  };
}
