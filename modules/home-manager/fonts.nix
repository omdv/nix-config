{
  lib,
  config,
  ...
}:
# Font profile system for consistent font configuration across applications.
#
# Provides three configurable font profiles:
# - monospace: For terminals, editors, and code
# - regular: For general UI text
# - icons: For icon fonts (e.g., Font Awesome, Nerd Fonts)
#
# Each profile specifies both the font family name and the package to install.
# This allows applications to reference fonts by profile rather than hardcoding names.
#
# Example usage:
#   fontProfiles = {
#     enable = true;
#     monospace = {
#       family = "FiraCode Nerd Font";
#       package = pkgs.nerd-fonts.fira-code;
#     };
#     regular = {
#       family = "Inter";
#       package = pkgs.inter;
#     };
#   };
let
  mkFontOption = kind: {
    family = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Family name for ${kind} font profile";
      example = "Fira Code";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = null;
      description = "Package for ${kind} font profile";
      example = "pkgs.fira-code";
    };
  };
  cfg = config.fontProfiles;
in {
  meta.maintainers = ["om"];

  options.fontProfiles = {
    enable = lib.mkEnableOption "Whether to enable font profiles";
    monospace = mkFontOption "monospace";
    regular = mkFontOption "regular";
    icons = mkFontOption "icons";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = [
      cfg.monospace.package
      cfg.regular.package
      cfg.icons.package
    ];
  };
}
