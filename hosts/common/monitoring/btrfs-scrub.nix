# Btrfs scrub monitoring with unified system notifications
# Requires: system-notifications.nix for notification framework
{
  lib,
  pkgs,
  ...
}: {
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  # Prevent scrub from firing at boot when the window was missed
  systemd.timers."btrfs-scrub--" = {
    timerConfig.Persistent = lib.mkForce false;
  };

  # Trigger notification services on completion
  # OnSuccess/OnFailure fire after the service fully exits (correct timing)
  # ExecStartPost was wrong - it fires right after the process starts with Type=simple
  systemd.services."btrfs-scrub--" = {
    onSuccess = ["btrfs-scrub-success-notify@%n.service"];
    onFailure = ["btrfs-scrub-failure-notify@%n.service"];
  };

  # Success notification service
  systemd.services."btrfs-scrub-success-notify@" = {
    description = "Notify on btrfs scrub success";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "btrfs-scrub-notify-success" ''
        #!${pkgs.bash}/bin/bash

        SCRUB_STATUS=$(${pkgs.btrfs-progs}/bin/btrfs scrub status / 2>&1 || echo "Status unavailable")

        MESSAGE="Btrfs scrub completed successfully
        Filesystem: /

        $SCRUB_STATUS"

        /etc/system-notify.sh "btrfs-scrub" "info" "$MESSAGE"
      '';
    };
  };

  # Failure notification service
  systemd.services."btrfs-scrub-failure-notify@" = {
    description = "Notify on btrfs scrub failure";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "btrfs-scrub-notify-failure" ''
        #!${pkgs.bash}/bin/bash

        MESSAGE="Btrfs scrub failed
        Filesystem: /

        Check systemd logs for details:
        journalctl -u btrfs-scrub--"

        /etc/system-notify.sh "btrfs-scrub" "critical" "$MESSAGE"
      '';
    };
  };
}
