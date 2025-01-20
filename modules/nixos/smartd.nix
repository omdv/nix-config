{ config, lib, ... }:

with lib;

let
  cfg = config.services.smartd;
in
{
  options.services.smartd.notifications = {
    customScript = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/current-system/sw/bin/custom-notification-script";
      description = "Path to a custom notification script that will be called when SMART events occur";
    };
  };

  config = mkIf cfg.enable {
    services.smartd.defaults.monitored = mkIf (cfg.notifications.customScript != null)
      "-m ${cfg.notifications.customScript}";
  };
}
