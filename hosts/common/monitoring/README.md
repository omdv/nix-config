# Unified System Notification Framework

A consistent approach to system event notifications using ntfy.sh across all monitoring services.

## Files in this Directory

- **`system-notifications.nix`** - Core notification framework (`/etc/system-notify.sh`)
- **`smartd.nix`** - SMART disk health monitoring
- **`btrfs-scrub.nix`** - Btrfs filesystem scrub monitoring
- **`zfs-scrub.nix`** - ZFS scrub and ZED event monitoring
- **`README.md`** - This documentation

**Note:** Base ZFS configuration (packages, trim, snapshot settings) is in `../zfs-base.nix`

## Overview

All system monitoring services (SMART, ZFS, btrfs) use a unified notification script that ensures consistent message formatting, severity levels, and delivery.

## Architecture

```text
[Service] → [Service Script] → [system-notify.sh] → [ntfy.sh]
   ↓              ↓                    ↓
smartd      /etc/smartd/notify.sh     Common
  ZED       /etc/zfs/zed.d/...        Message
btrfs       systemd hooks             Format
```

## Message Format

All notifications follow this standardized format:

```text
Title: [hostname] System Alert: [program]

Host: hostname
Program: smartd/zed/btrfs-scrub
Severity: critical/warning/info
---
[event-specific details]
```

## Severity Levels

| Severity | ntfy Priority | Tags | Use Case |
|----------|--------------|------|----------|
| **critical** | urgent | warning, red_circle, system | Disk failures, pool degradation, critical errors |
| **warning** | high | warning, system | Non-critical issues, state changes |
| **info** | default | white_check_mark, system | Successful completions (scrubs, etc.) |

## Configuration

### Secret Management

The ntfy topic is stored as a secret:

```nix
sops.secrets.ntfy_system_topic = mkSecret {
  name = "ntfy_system_topic";
  sopsFile = ./secrets.yaml;
};
```

All hosts that use system notifications must have this secret defined.

### Core Module

`system-notifications.nix` provides:

- `/etc/system-notify.sh` - Main notification script
- `/etc/systemd/system-notify-wrapper.sh` - Systemd integration wrapper

### Service Integration

Each monitoring service has its own wrapper script that:

1. Receives service-specific events
2. Determines appropriate severity
3. Formats event details
4. Calls unified `system-notify.sh`

## Monitoring Services

### SMART Monitoring (smartd)

**Module:** `monitoring/smartd.nix`
**Script:** `/etc/smartd/notify.sh`
**Events:**

- Disk failures → **critical**
- Pre-failure warnings → **warning**
- Test emails → **info**

**Environment Variables:**

- `SMARTD_MESSAGE` - Event description
- `SMARTD_FAILTYPE` - Failure type
- `SMARTD_DEVICE` - Device path

### ZFS Scrub & Event Daemon (ZED)

**Module:** `monitoring/zfs-scrub.nix`
**Base config:** `../zfs-base.nix` (packages, trim, snapshot)
**Script:** `/etc/zfs/zed.d/ntfy-notify.sh`
**Events:**

- Checksum/IO errors → **critical**
- Pool degraded/faulted → **critical**
- Scrub/resilver completion → **info**
- State changes → **warning**

**Symlinked for event types:**

- `checksum-ntfy.sh`
- `io-ntfy.sh`
- `scrub_finish-ntfy.sh`
- `resilver_finish-ntfy.sh`
- `statechange-ntfy.sh`
- `ereport.fs.zfs.*-ntfy.sh`

**Environment Variables:**

- `ZEVENT_CLASS` - Event type
- `ZEVENT_POOL` - Pool name
- `ZEVENT_VDEV_PATH` - Device path
- `ZEVENT_VDEV_STATE` - Device state

### Btrfs Auto-Scrub

**Module:** `monitoring/btrfs-scrub.nix`
**Integration:** systemd service hooks
**Events:**

- Scrub completion → **info**
- Scrub failure → **critical**

**Hooks:**

- `ExecStartPost` - Successful completion
- `onFailure` - Failure notification service

## Testing

### Test Notification Script Directly

```bash
# Test with info severity
/etc/system-notify.sh "test" "info" "This is a test notification"

# Test with warning
/etc/system-notify.sh "test" "warning" "Warning level test"

# Test with critical
/etc/system-notify.sh "test" "critical" "Critical alert test"
```

### Test Service-Specific Notifications

#### SMART

```bash
# Send test email (if configured)
smartctl -t short /dev/sda
```

#### ZFS

```bash
# Trigger scrub completion notification
zpool scrub pool
# Wait for completion...

# Or manually trigger script
cd /etc/zfs/zed.d
ZEVENT_CLASS="scrub_finish" ZEVENT_POOL="pool" ./ntfy-notify.sh
```

#### Btrfs

```bash
# Manually trigger scrub (will notify on completion)
btrfs scrub start /
btrfs scrub status /
```

## Adding New Notification Sources

To add a new service that needs notifications:

1. **Import** `system-notifications.nix` in your host configuration

2. **Create service script** that calls `/etc/system-notify.sh`:

   ```bash
   #!/bin/bash
   PROGRAM="my-service"
   SEVERITY="warning"  # or critical, info
   MESSAGE="Event details here"

   /etc/system-notify.sh "$PROGRAM" "$SEVERITY" "$MESSAGE"
   ```

3. **Integrate** with your service:
   - For daemons: Add notification script to service config
   - For systemd: Use `ExecStartPost` or `onFailure`
   - For cron: Call directly from cron script

4. **Test** your integration before deploying

## Notification Examples

### SMART Disk Failure

```text
Title: [framework] System Alert: smartd

Host: framework
Program: smartd
Severity: critical
---
Device: /dev/nvme0n1
Failure Type: FailedHealthCheck

Device has exceeded threshold temperature
```

### ZFS Scrub Completion

```text
Title: [homelab] System Alert: zed

Host: homelab
Program: zed
Severity: info
---
Event: scrub_finish
Pool: pool
```

### Btrfs Scrub Failure

```text
Title: [framework] System Alert: btrfs-scrub

Host: framework
Program: btrfs-scrub
Severity: critical
---
Btrfs scrub failed
Filesystem: /
Service: btrfs-scrub--

Check systemd logs for details:
journalctl -u btrfs-scrub--
```

## Troubleshooting

### Notifications Not Arriving

1. **Check secret is readable:**

   ```bash
   cat /run/user-secrets/ntfy-system-topic
   ```

2. **Test notification script:**

   ```bash
   /etc/system-notify.sh "test" "info" "Hello"
   ```

3. **Check service logs:**

   ```bash
   journalctl -u smartd
   journalctl -u zfs-zed
   journalctl -u btrfs-scrub--
   ```

4. **Verify curl can reach ntfy.sh:**

   ```bash
   curl -v https://ntfy.sh/your-topic -d "test"
   ```

### Wrong Severity Levels

Check service-specific wrapper scripts:

- `/etc/smartd/notify.sh`
- `/etc/zfs/zed.d/ntfy-notify.sh`

Adjust severity mapping in the case statements.

### Missing Event Details

Increase service verbosity:

- **ZFS:** Already set with `ZED_NOTIFY_VERBOSE = 1`
- **SMART:** Check smartd configuration
- **Btrfs:** Check systemd service output

## Security Considerations

- **Secret storage:** ntfy topic stored in SOPS-encrypted secrets.yaml
- **Script permissions:** All scripts are 0755 (world-readable, only root writable)
- **Secret access:** Only readable by root and services running as root
- **Network:** Notifications sent over HTTPS to ntfy.sh

## Related Documentation

- [SMART Monitoring](./smartd.nix)
- [ZFS Scrub Monitoring](./zfs-scrub.nix)
- [ZFS Base Configuration](../zfs-base.nix)
- [Btrfs Scrub Monitoring](./btrfs-scrub.nix)
- [Secrets Management](../../../AGENTS.md#secrets-management)
