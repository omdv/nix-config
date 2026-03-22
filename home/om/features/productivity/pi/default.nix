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
      "${piAgentDir}/extensions/files"
    ];
  };

in {
  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettings;

  home.file.".pi/agent/extensions/security/index.ts".source =
    ./extensions/security/index.ts;

  home.file.".pi/agent/extensions/files/index.ts".source =
    ./extensions/files/index.ts;
}
