{ pkgs, ... }:
let
  pname = "octarine";
  version = "0.28.2";
  octarineAppImage = pkgs.fetchurl {
    url = "https://pub-3d35bc018fc54f11bde129e3e73e8002.r2.dev/0.28.2/linux/Octarine_0.28.2_amd64.AppImage";
    sha256 = "sha256-JUfahfELgz9vJ1r+7rknCR7LV54tn3Wpt/TFz73rl/M=";
    name = "${pname}-${version}.AppImage";
  };
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "octarine" ''
      #!${stdenv.shell}
      ${lib.getExe pkgs.appimage-run} ${octarineAppImage} "$@"
    '')
  ];

  xdg.desktopEntries = {
    octarine = {
      name = "Octarine";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "octarine %F";
      icon = "octarine";
      mimeType = [
        "text/english"
        "text/plain"
        "text/markdown"
      ];
      terminal = false;
      type = "Application";
      categories = [
        "Office"
        "TextEditor"
      ];
    };
  };
}
