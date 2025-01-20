{ config, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.smartmontools
    pkgs.curl
  ];

  # Create notification script for NTFY
  environment.etc."smartd/notify.sh" = {
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      NTFY_TOPIC=$(cat ${config.sops.secrets.ntfy_system_topic.path})
      NTFY_URL=https://ntfy.sh/$NTFY_TOPIC

      ${pkgs.curl}/bin/curl -H "Title: SMART Alert" \
        -H "Priority: high" \
        -H "Tags: warning" \
        -d "$SMARTD_MESSAGE" \
        "$NTFY_URL"
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
