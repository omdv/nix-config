{
  config,
  lib,
  pkgs,
}: {
  repository,
  sourceDirectories,
  frequency,
}: let
  homeDirectory = config.home.homeDirectory;
  backupKey = "/run/user-secrets/backup-passphrase";
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
    backups.borgbase = {
      location = {
        inherit sourceDirectories;
        repositories = [repository];
        extraConfig = {
          remote_path = "borg1";
          exclude_patterns = [
            "*.pyc"
            "${homeDirectory}/.local"
            "${homeDirectory}/.cache"
            "${homeDirectory}/.ssh"
            "${homeDirectory}/.config/borg"
            "${homeDirectory}/*/node_modules/"
            "${homeDirectory}/*/Trash/"
            "${homeDirectory}/*/.venv/"
            "${homeDirectory}/Jts"
            "${homeDirectory}/.asdf"
            "${homeDirectory}/.gnupg"
            "${homeDirectory}/.nix-profile"
            "${homeDirectory}/.nix-defexpr"
          ];
          exclude_if_present = [".nobackup"];
          exclude_caches = true;
        };
      };
      storage = {
        encryptionPasscommand = mkScript {
          name = "borg-encryption-pass";
          deps = [pkgs.coreutils];
          script = ''
            ${pkgs.coreutils}/bin/cat ${backupKey}
          '';
        };
        extraConfig = {
          ssh_command = "ssh -i ${homeDirectory}/.ssh/id_rsa";
          borg_base_directory = "${homeDirectory}/";
        };
      };
      retention = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 2;
      };
      consistency.checks = [
        {
          name = "repository";
          frequency = "1 month";
        }
        {
          name = "archives";
          frequency = "2 months";
        }
      ];
    };
  };

  services.borgmatic = {
    enable = true;
    inherit frequency;
  };
}
