{lib, ...}:
# Centralized wallpaper configuration that can be shared across desktop environments.
#
# Provides a single place to set the wallpaper, which can then be referenced
# by different desktop environments (i3, GNOME, etc.) and login managers.
#
# Supports both local file paths and URLs.
#
# Example usage:
#   # With a URL
#   wallpaper.url = "https://example.com/wallpaper.jpg";
#
#   # Reference in GNOME
#   dconf.settings."org/gnome/desktop/background".picture-uri-dark = config.wallpaper.url;
#
#   # With a local path
#   wallpaper.path = ./wallpapers/mountains.jpg;
#
#   # Reference in i3
#   xsession.windowManager.i3.config.startup = [{
#     command = "feh --bg-scale ${config.wallpaper.path}";
#   }];
let
  inherit (lib) types mkOption;
in {
  meta.maintainers = ["om"];

  options.wallpaper = {
    path = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Local path to wallpaper image";
      example = ./wallpapers/mountains.jpg;
    };

    url = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "URL to wallpaper image";
      example = "https://example.com/wallpaper.jpg";
    };
  };
}
