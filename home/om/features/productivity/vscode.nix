{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      # General
      "editor.fontSize" = 16;
      "editor.fontFamily" = "'FiraCode Nerd Font', 'mono', monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.multiCursorModifier" = "ctrlCmd";
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font', 'mono', monospace";
      "window.zoomLevel" = 1;
      "workbench.startupEditor" = "none";
      "explorer.compactFolders" = false;
      # Copilot
      "github.copilot.enable"= {
        "*" = true;
        "yaml" = true;
        "plaintext" = false;
        "markdown" = false;
      };
      # Whitespace
      "files.trimTrailingWhitespace" = true;
      "files.trimFinalNewlines" = true;
      "files.insertFinalNewline" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      # Git
      "git.enableCommitSigning" = true;
      "git-graph.repository.sign.commits" = true;
      "git-graph.repository.sign.tags" = true;
      "git-graph.repository.commits.showSignatureStatus" = true;
      # Styling
      "window.autoDetectColorScheme" = true;
      "workbench.preferredDarkColorTheme" = "Default Dark Modern";
      "workbench.preferredLightColorTheme" = "Default Light Modern";
      "workbench.iconTheme" = "material-icon-theme";
      "material-icon-theme.activeIconPack" = "none";
      "material-icon-theme.folders.theme" = "classic";
      # Other
      "telemetry.telemetryLevel" = "off";
      "update.showReleaseNotes" = false;
    };
  };
}
