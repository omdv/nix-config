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
            "/pool"
          ];
          repositories = [ "ssh://nnyrw2md@nnyrw2md.repo.borgbase.com/./repo" ];
          extraConfig = {
            remote_path = "borg1";
            exclude_patterns = [
              "*.pyc"
              "/home/me/.cache"
              "/home/me/.ssh"
              "/home/me/.config/borg"
              "/home/me/*/node_modules/"
              "/home/me/*/Trash/"
              "/home/me/*/.venv/"
              "/home/me/Jts"
              "/home/me/.asdf"
              "/home/me/.gnupg"
              "/home/me/.nix-profile"
              "/home/me/.nix-defexpr"
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

  # borgmatic service - run every 3 hours
  services.borgmatic = {
    enable = true;
    frequency = "*-*-* *:00/3:00";
  };
}
