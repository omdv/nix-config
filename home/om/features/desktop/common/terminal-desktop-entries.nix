{
  xdg.desktopEntries = {
    k9s = {
      name = "k9s";
      genericName = "k8s CLI";
      comment = "Monitor and control k8s clusters";
      exec = "k9s";
      icon = "kubernetes";
      terminal = true;
      categories = [
        "Network"
        "ConsoleOnly"
      ];
      type = "Application";
    };

    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "kitty -e nvim %F";
      icon = "nvim";
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
      terminal = true;
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
      ];
    };
  };
}
