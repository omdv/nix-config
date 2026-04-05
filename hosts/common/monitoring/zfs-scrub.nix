# ZFS scrub monitoring and ZED event notifications
# Requires: zfs-base.nix for base ZFS setup
# Requires: system-notifications.nix for notification framework
{
  config,
  pkgs,
  ...
}: {
  # ZED notification script using unified system-notify
  environment.etc."zfs/zed.d/ntfy-notify.sh" = {
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      # ZFS event notification
      # Environment variables provided by ZED:
      # - ZEVENT_CLASS: Event type (checksum, io, resilver_finish, scrub_finish, etc.)
      # - ZEVENT_SUBCLASS: Event subclass
      # - ZEVENT_POOL: Pool name
      # - ZEVENT_VDEV_PATH: Device path
      # - ZEVENT_VDEV_STATE: Device state

      # Determine severity based on event class
      case "$ZEVENT_CLASS" in
        checksum|io|ereport.fs.zfs.*)
          SEVERITY="critical"
          ;;
        statechange)
          # Check if pool is degraded or faulted
          case "$ZEVENT_VDEV_STATE" in
            DEGRADED|FAULTED|UNAVAIL|REMOVED)
              SEVERITY="critical"
              ;;
            *)
              SEVERITY="warning"
              ;;
          esac
          ;;
        resilver_finish|scrub_finish|sysevent.fs.zfs.resilver_finish|sysevent.fs.zfs.scrub_finish)
          SEVERITY="info"
          ;;
        *)
          SEVERITY="warning"
          ;;
      esac

      # Format message with event details
      MESSAGE="Event: $ZEVENT_CLASS"
      [ -n "$ZEVENT_SUBCLASS" ] && MESSAGE="$MESSAGE ($ZEVENT_SUBCLASS)"
      MESSAGE="$MESSAGE
      Pool: $ZEVENT_POOL"
      [ -n "$ZEVENT_VDEV_PATH" ] && MESSAGE="$MESSAGE
      Device: $ZEVENT_VDEV_PATH"
      [ -n "$ZEVENT_VDEV_STATE" ] && MESSAGE="$MESSAGE
      State: $ZEVENT_VDEV_STATE"
      [ -n "$ZEVENT_EID" ] && MESSAGE="$MESSAGE
      Event ID: $ZEVENT_EID"
      [ -n "$ZEVENT_TIME_STRING" ] && MESSAGE="$MESSAGE
      Time: $ZEVENT_TIME_STRING"
      [ -n "$ZEVENT_HISTORY_HOST" ] && MESSAGE="$MESSAGE
      Source Host: $ZEVENT_HISTORY_HOST"
      [ -n "$ZEVENT_HISTORY_DSNAME" ] && MESSAGE="$MESSAGE
      Dataset: $ZEVENT_HISTORY_DSNAME"
      [ -n "$ZEVENT_HISTORY_INTERNAL_NAME" ] && MESSAGE="$MESSAGE
      Internal: $ZEVENT_HISTORY_INTERNAL_NAME"

      # Call unified notification script
      exec /etc/system-notify.sh "zed" "$SEVERITY" "$MESSAGE"
    '';
  };

  services.zfs = {
    zed = {
      enableMail = false;
      settings = {
        # Increase verbosity for better event details
        ZED_NOTIFY_VERBOSE = 1;
        ZED_NOTIFY_DATA = 1;
      };
    };

    autoScrub = {
      enable = true;
      pools = ["pool"];
      interval = "monthly";
    };
  };

  # Create symlinks for different event types
  # ZED automatically executes scripts matching event patterns
  systemd.services.zfs-zed.preStart = ''
    cd /etc/zfs/zed.d
    chmod +x ntfy-notify.sh

    # Symlink for different event types
    for event in \
      checksum \
      io \
      resilver_finish \
      scrub_finish \
      sysevent.fs.zfs.resilver_finish \
      sysevent.fs.zfs.scrub_finish \
      statechange \
      data \
      ereport.fs.zfs.checksum \
      ereport.fs.zfs.io
    do
      ln -sf ntfy-notify.sh ''${event}-ntfy.sh || true
    done
  '';
}
