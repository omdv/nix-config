{config, ...}: let
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";

  piSettings = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.3-codex";
    theme = "dark";
    hideThinkingBlock = true;
    enabledModels = [
      "glm-5.1"
      "gpt-5.3-codex"
      "deepseek-v4-pro"
      "deepseek/deepseek-v4-pro"
    ];
    packages = [
      "npm:pi-lens"
    ];
    extensions = [
      "${piAgentDir}/extensions/security"
      "${piAgentDir}/extensions/hashline"
      "${piAgentDir}/extensions/dcp"
    ];
  };
in {
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";

  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettings;
  home.file.".pi/agent/extensions/security" = {
    source = ./extensions/security;
    recursive = true;
  };
  home.file.".pi/agent/extensions/hashline" = {
    source = ./extensions/hashline;
    recursive = true;
  };
  home.file.".pi/agent/extensions/dcp" = {
    source = ./extensions/dcp;
    recursive = true;
  };
  home.file.".pi/agent/skills/analyze-repo" = {
    source = ./skills/analyze-repo;
    recursive = true;
  };
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
}
