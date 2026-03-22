# SMART disk monitoring with unified system notifications
{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.smartmontools
  ];

  # SMART notification script using unified system-notify
  environment.etc."smartd/notify.sh" = {
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      # SMART event notification
      # Environment variables provided by smartd:
      # - SMARTD_MESSAGE: Event description
      # - SMARTD_FAILTYPE: Type of failure
      # - SMARTD_DEVICE: Device path

      # Determine severity based on failure type
      case "$SMARTD_FAILTYPE" in
        *EmailTest*)
          SEVERITY="info"
          ;;
        *FailedHealthCheck*|*FailedReadSmartData*)
          SEVERITY="critical"
          ;;
        *)
          SEVERITY="warning"
          ;;
      esac

      # Format message with device details
      MESSAGE="Device: $SMARTD_DEVICE
      Failure Type: $SMARTD_FAILTYPE

      $SMARTD_MESSAGE"

      # Call unified notification script
      exec /etc/system-notify.sh "smartd" "$SEVERITY" "$MESSAGE"
    '';
  };

  services.smartd = {
    enable = true;
    autodetect = true;
    notifications = {
      mail.enable = false;
      customScript = "/etc/smartd/notify.sh";
    };
  };
}
