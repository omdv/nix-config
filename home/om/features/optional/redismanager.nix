{ pkgs, ... }:
let
  pname = "AnotherRedisDesktopManager";
  version = "1.7.1";
  ardmAppImage = pkgs.fetchurl {
    url = "https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v1.7.1/Another-Redis-Desktop-Manager-linux-1.7.1-x86_64.AppImage";
    sha256 = "sha256-1234567890";
    name = "${pname}-${version}.AppImage";
  };
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "AnotherRedisDesktopManager" ''
      #!${stdenv.shell}
      ${lib.getExe pkgs.appimage-run} ${ardmAppImage} "$@"
    '')
  ];
}
