# Unified system notification framework
# Provides consistent ntfy.sh notifications for all system events
# (SMART failures, ZFS events, btrfs scrubs, etc.)
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Shared notification script used by all system monitoring services
  notifyScript = pkgs.writeScript "system-notify" ''
    #!${pkgs.bash}/bin/bash

    # Usage: system-notify <program> <severity> <message>
    # program: smartd, zed, btrfs-scrub, etc.
    # severity: critical, warning, info
    # message: Event description

    PROGRAM="''${1:-unknown}"
    SEVERITY="''${2:-info}"
    MESSAGE="''${3:-No message provided}"
    HOSTNAME="$(${pkgs.hostname}/bin/hostname)"

    # Read secret ntfy topic
    if [ ! -r "${config.sops.secrets.ntfy_system_topic.path}" ]; then
      echo "ERROR: Cannot read ntfy_system_topic secret" >&2
      exit 1
    fi

    NTFY_TOPIC=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.ntfy_system_topic.path})
    NTFY_URL="https://ntfy.sh/$NTFY_TOPIC"

    # Map severity to ntfy priority and tags
    case "$SEVERITY" in
      critical)
        PRIORITY="urgent"
        TAGS="warning,red_circle,system"
        ;;
      warning)
        PRIORITY="high"
        TAGS="warning,system"
        ;;
      info)
        PRIORITY="default"
        TAGS="white_check_mark,system"
        ;;
      *)
        PRIORITY="default"
        TAGS="system"
        ;;
    esac

    # Format consistent message body
    BODY="Host: $HOSTNAME
    Program: $PROGRAM
    Severity: $SEVERITY
    ---
    $MESSAGE"

    # Send notification
    ${pkgs.curl}/bin/curl -sf \
      -H "Title: [$HOSTNAME] System Alert: $PROGRAM" \
      -H "Priority: $PRIORITY" \
      -H "Tags: $TAGS" \
      -d "$BODY" \
      "$NTFY_URL" || echo "Failed to send notification" >&2
  '';
in {
  # Ensure curl is available for all notification scripts
  environment.systemPackages = [pkgs.curl];

  # Make the shared notification script available system-wide
  environment.etc."system-notify.sh" = {
    mode = "0755";
    source = notifyScript;
  };

  # Add systemd-notify wrapper for easier integration
  environment.etc."systemd/system-notify-wrapper.sh" = {
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      # Wrapper for systemd services that want to send notifications
      # Reads from stdin if MESSAGE is not set

      PROGRAM="''${PROGRAM:-systemd}"
      SEVERITY="''${SEVERITY:-info}"
      MESSAGE="''${MESSAGE:-$(${pkgs.coreutils}/bin/cat)}"

      exec /etc/system-notify.sh "$PROGRAM" "$SEVERITY" "$MESSAGE"
    '';
  };
}
