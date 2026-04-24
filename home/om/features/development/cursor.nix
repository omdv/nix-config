{
  pkgs,
  lib,
  ...
}: let
  pname = "cursor";
  version = "3.0";
  cursorAppImage = pkgs.fetchurl {
    url = "https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/3.0";
    sha256 = "sha256-AAAA";
    name = "${pname}-${version}.AppImage";
  };
in {
  home.packages = with pkgs; [
    (writeShellScriptBin "cursor" ''
      #!${stdenv.shell}
      ${lib.getExe pkgs.appimage-run} ${cursorAppImage} "$@"
    '')
  ];

  xdg.desktopEntries = {
    cursor = {
      name = "Cursor";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "cursor %F";
      icon = "cursor";
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
        "Development"
      ];
    };
  };
}
