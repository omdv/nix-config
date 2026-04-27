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
    ];
    extensions = [
      "${piAgentDir}/extensions/security"
      "${piAgentDir}/extensions/files"
      "${piAgentDir}/extensions/hashline"
      "${piAgentDir}/extensions/context"
      "${piAgentDir}/extensions/notify"
      "${piAgentDir}/extensions/session-breakdown"
    ];
  };
in {
  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettings;
  home.file.".pi/agent/extensions/security" = {
    source = ./extensions/security;
    recursive = true;
  };
  home.file.".pi/agent/extensions/files" = {
    source = ./extensions/files;
    recursive = true;
  };
  home.file.".pi/agent/extensions/hashline" = {
    source = ./extensions/hashline;
    recursive = true;
  };
  home.file.".pi/agent/extensions/context" = {
    source = ./extensions/context;
    recursive = true;
  };
  home.file.".pi/agent/extensions/notify" = {
    source = ./extensions/notify;
    recursive = true;
  };
  home.file.".pi/agent/extensions/session-breakdown" = {
    source = ./extensions/session-breakdown;
    recursive = true;
  };
  home.file.".pi/agent/skills/analyze-repo" = {
    source = ./skills/analyze-repo;
    recursive = true;
  };
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;

  # home.file.".pi/agent/models.json".source =
  #   ./models.json;
}
