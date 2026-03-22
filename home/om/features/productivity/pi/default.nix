{ config, ... }:
let
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";

  piSettings = {
    defaultProvider = "anthropic";
    defaultModel = "claude-sonnet-4-5";
    theme = "dark";
    hideThinkingBlock = true;

    extensions = [
      "${piAgentDir}/extensions/security"
    ];
  };

in {
  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettings;

  home.file.".pi/agent/extensions/security/index.ts".source =
    ./extensions/security/index.ts;
}
