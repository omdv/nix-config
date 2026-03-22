{lib, ...}:
# HiDPI scaling configuration for i3wm environments.
#
# Provides centralized DPI, font size, and cursor size settings that can be
# referenced by various applications (i3, GTK apps, Xresources, etc.).
#
# This module only defines options; actual application of these settings
# happens in the i3wm configuration and other desktop configs.
#
# Example usage:
#   i3scaling = {
#     dpi = 144;           # For HiDPI displays (e.g., 1.5x scaling)
#     gtkFontSize = 14;    # Larger fonts for GTK apps
#     cursorSize = 32;     # Larger cursor for visibility
#   };
let
  inherit (lib) types mkOption;
in {
  meta.maintainers = ["om"];

  options.i3scaling = {
    dpi = mkOption {
      type = types.int;
      default = 1;
    };
    gtkFontSize = mkOption {
      type = types.int;
      default = 12;
    };
    cursorSize = mkOption {
      type = types.int;
      default = 18;
    };
  };
}
