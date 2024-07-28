{
  programs.vscode = {
    enable = true;
    userSettings = {
      # General
      "editor.fontSize" = 14;
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
      ## Language supports
      # Nix Language
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
    };
  };

  # add runtime parameter
  home.file.".vscode/argv.json".text = builtins.toJSON {
    "enable-crash-reporter" = false;
    "password-store" = "gnome-libsecret";
  };

  xdg.desktopEntries = {
    code = {
      name = "VSCode";
      genericName = "Development environment";
      comment = "Edit text files";
      exec = "code %F";
      icon = "code";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = false;
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
      ];
    };
  };
}
