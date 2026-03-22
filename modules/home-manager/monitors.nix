{
  lib,
  config,
  ...
}:
# Multi-monitor configuration system for Wayland and X11 environments.
#
# Provides a declarative way to configure monitor layouts with support for:
# - Resolution and refresh rate
# - Position (x, y coordinates)
# - Primary monitor designation
# - Per-monitor workspace assignments
# - Scaling (for HiDPI)
#
# Includes validation to ensure exactly one monitor is marked as primary.
#
# Example usage:
#   monitors = [
#     {
#       name = "eDP-1";
#       primary = true;
#       width = 2256;
#       height = 1504;
#       refreshRate = 60;
#       x = 0;
#       y = 0;
#       scale = 1.5;
#     }
#     {
#       name = "HDMI-1";
#       width = 1920;
#       height = 1080;
#       x = 2256;
#       y = 0;
#       workspace = "2";
#     }
#   ];
let
  inherit (lib) mkOption types;
in {
  meta.maintainers = ["om"];

  options.monitors = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            example = "DP-1";
          };
          primary = mkOption {
            type = types.bool;
            default = false;
          };
          width = mkOption {
            type = types.int;
            example = 1920;
          };
          height = mkOption {
            type = types.int;
            example = 1080;
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
          };
          x = mkOption {
            type = types.int;
            default = 0;
          };
          y = mkOption {
            type = types.int;
            default = 0;
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
          workspace = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
          };
        };
      }
    );
    default = [];
  };
  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ];
  };
}
