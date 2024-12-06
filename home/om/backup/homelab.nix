{
  lib,
  pkgs,
  ...
}: let
  backup_key = "/run/user-secrets/backup-passphrase";
  mkScript = {
    name ? "script",
    deps ? [],
    script ? "",
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = script;
      runtimeInputs = deps;
    });
in {
  programs.borgmatic = {
    enable = true;
    backups = {
      borgbase = {
        location = {
          sourceDirectories = [
            "/home/om"
            "/pool/media"
            "/pool/databases"
          ];
          repositories = [ "ssh://nnyrw2md@nnyrw2md.repo.borgbase.com/./repo" ];
          extraConfig = {
            remote_path = "borg1";
            exclude_patterns = [
              "*.pyc"
              "/home/om/.cache"
              "/home/om/.ssh"
              "/home/om/.config/borg"
              "/home/om/*/node_modules/"
              "/home/om/*/Trash/"
              "/home/om/*/.venv/"
              "/home/om/Jts"
              "/home/om/.asdf"
              "/home/om/.gnupg"
              "/home/om/.nix-profile"
              "/home/om/.nix-defexpr"
            ];
            exclude_if_present = [ ".nobackup" ];
            exclude_caches = true;
          };
        };
        storage = {
          encryptionPasscommand = mkScript {
            name = "borg-encryption-pass";
            script = ''
              cat ${backup_key}
            '';
          };
          extraConfig = {
            ssh_command = "ssh -i /home/om/.ssh/id_rsa";
            borg_base_directory = "/home/om/";
          };
        };
        retention = {
          keepDaily = 7;
          keepWeekly = 4;
          keepMonthly = 2;
        };
      };
    };
  };

  # custom service without inhibit
  systemd.user.services.borgmatic-backup = {
    Unit = {
      Description = "Borgmatic backup service";
      ConditionACPower = false;
    };

    Service = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
      IOWeight = 100;

      Restart = "no";
      LogRateLimitIntervalSec = 0;

      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3m";
      ExecStart = ''
        ${pkgs.borgmatic}/bin/borgmatic \
          --stats \
          --verbosity -1 \
          --list \
          --syslog-verbosity 1
      '';
    };
  };

  # Timer to run the backup every 3 hours
  systemd.user.timers.borgmatic-backup = {
    Unit = {
      Description = "Timer for borgmatic backup service";
    };

    Timer = {
      OnCalendar = "*-*-* *:00/3:00";
      Persistent = true;
    };

    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
