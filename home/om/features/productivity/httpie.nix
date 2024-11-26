{ pkgs, ... }:
let
  pname = "httpie";
  version = "2024";
  cursorAppImage = pkgs.fetchurl {
    url = "https://github.com/httpie/desktop/releases/download/v2024.1.2/HTTPie-2024.1.2.AppImage";
    sha256 = "sha256-OOP1l7J2BgO3nOPSipxfwfN/lOUsl80UzYMBosyBHrM=";
    name = "${pname}-${version}.AppImage";
  };
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "httpie" ''
      #!${stdenv.shell}
      ${lib.getExe pkgs.appimage-run} ${cursorAppImage} "$@"
    '')
  ];

  xdg.desktopEntries = {
    httpie = {
      name = "Httpie";
      genericName = "API Management";
      comment = "HTTP client";
      exec = "httpie %F";
      icon = "httpie";
      mimeType = [
      ];
      terminal = false;
      type = "Application";
      categories = [
        "Utility"
        "Development"
      ];
    };
  };
}
