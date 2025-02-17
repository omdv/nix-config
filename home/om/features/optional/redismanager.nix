{ pkgs, ... }:
let
  pname = "AnotherRedisDesktopManager";
  version = "1.7.1";
  ardmAppImage = pkgs.fetchurl {
    url = "https://github.com/qishibo/AnotherRedisDesktopManager/releases/download/v1.7.1/Another-Redis-Desktop-Manager-linux-1.7.1-x86_64.AppImage";
    sha256 = "sha256-XuS4jsbhUproYUE2tncT43R6ErYB9WTg6d7s16OOxFQ=";
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

  xdg.desktopEntries."another-redis-desktop-manager" = {
    name = "Another Redis Desktop Manager";
    genericName = "Redis GUI Client";
    exec = "AnotherRedisDesktopManager";
    icon = "redis";
    categories = [ "Development" "Utility" ];
    comment = "A faster, better and more stable redis desktop manager.";
  };
}
