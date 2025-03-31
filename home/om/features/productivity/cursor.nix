{ pkgs, ... }:
let
  pname = "cursor";
  version = "0.48.6";
  cursorAppImage = pkgs.fetchurl {
    url = "https://downloader.cursor.sh/linux/appImage/x64";
    sha256 = "sha256-5MGWJi8TP+13jZf6YMMUU5uYY/3OBTFxtGpirvgj8ZI=";
    name = "${pname}-${version}.AppImage";
  };
in
{
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
