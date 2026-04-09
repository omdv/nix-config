{
  config,
  pkgs,
  ...
}: let
  piAgentDir = "${config.home.homeDirectory}/.pi/agent";

  piSettings = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.3-codex";
    theme = "dark";
    hideThinkingBlock = true;
    enabledModels = [
      "glm-5.1"
      "gpt-5.3-codex"
      "claude-sonnet-4-5"
      "claude-sonnet-4-6"
      "claude-opus-4-5"
      "claude-opus-4-6"
    ];
    extensions = [
      "${piAgentDir}/extensions/security"
      "${piAgentDir}/extensions/files"
      "${piAgentDir}/extensions/hashline"
      "${piAgentDir}/extensions/context"
      "${piAgentDir}/extensions/notify"
      "${piAgentDir}/extensions/session-breakdown"
      # pkgs.pi-dynamic-context-pruning
    ];
  };
in {
  home.file.".pi/agent/settings.json".text = builtins.toJSON piSettings;

  home.file.".pi/agent/extensions/security/index.ts".source =
    ./extensions/security/index.ts;

  home.file.".pi/agent/extensions/files/index.ts".source =
    ./extensions/files/index.ts;

  home.file.".pi/agent/extensions/hashline/index.ts".source =
    ./extensions/hashline/index.ts;

  home.file.".pi/agent/extensions/context/index.ts".source =
    ./extensions/context/index.ts;

  home.file.".pi/agent/extensions/notify/index.ts".source =
    ./extensions/notify/index.ts;

  home.file.".pi/agent/extensions/session-breakdown/index.ts".source =
    ./extensions/session-breakdown/index.ts;

  home.file.".pi/agent/skills/analyze-repo/SKILL.md".source =
    ./skills/analyze-repo/SKILL.md;

  home.file.".pi/agent/AGENTS.md".source =
    ./AGENTS.md;

  # home.file.".pi/agent/models.json".source =
  #   ./models.json;
}
