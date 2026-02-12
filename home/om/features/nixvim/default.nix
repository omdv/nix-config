{ inputs, ...}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./settings.nix
    ./bufferline.nix
    ./css-color.nix
    ./cursorline.nix
    ./fzf.nix
    ./nvim-tree.nix
    ./statusline
    ./lazy.nix
    ./web-devicons.nix
  ];

  programs.nixvim = {
    enable = true;
  };

  home.sessionVariables.EDITOR = "nvim";

  xdg.desktopEntries = {
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
