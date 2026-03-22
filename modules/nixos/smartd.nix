{
  config,
  lib,
  ...
}:
# Extension to the built-in smartd service that adds support for custom notification scripts.
#
# Allows you to specify a custom script to be called when SMART disk events occur,
# useful for integrating with notification services like ntfy.sh.
#
# Example usage:
#   services.smartd = {
#     enable = true;
#     notifications.customScript = "/path/to/notification-script";
#   };
with lib; let
  cfg = config.services.smartd;
in {
  meta.maintainers = ["om"];

  options.services.smartd.notifications = {
    customScript = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/current-system/sw/bin/custom-notification-script";
      description = lib.mdDoc ''
        Path to a custom notification script that will be called when SMART events occur.

        The script will be invoked by smartd when disk events are detected, with
        environment variables containing event details. Useful for integrating with
        notification services like ntfy.sh.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.smartd.defaults.monitored =
      mkIf (cfg.notifications.customScript != null)
      "-m ${cfg.notifications.customScript}";
  };
}
