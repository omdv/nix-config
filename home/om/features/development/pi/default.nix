{config, pkgs, ...}: let
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
    packages = [
      "npm:pi-mcp-adapter"
      "npm:context-mode"
      "npm:pi-lens"
    ];
    extensions = [
      "${piAgentDir}/extensions/security"
      "${piAgentDir}/extensions/files"
      "${piAgentDir}/extensions/hashline"
    ];
  };

  piMcp = {
    mcpServers = {
      context-mode = {
        command = "${pkgs.context-mode}/bin/context-mode";
      };
    };
  };
in {
  home.packages = [
    pkgs.context-mode
  ];

  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";

  home.file.".pi/agent/mcp.json".text = builtins.toJSON piMcp;
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
  home.file.".pi/agent/skills/analyze-repo" = {
    source = ./skills/analyze-repo;
    recursive = true;
  };
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;
}
