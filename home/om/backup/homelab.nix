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
            deps = [ pkgs.coreutils ];
            script = ''
              ${pkgs.coreutils}/bin/cat ${backup_key}
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

  # borgmatic service - run daily at 2 AM
  services.borgmatic = {
    enable = true;
    frequency = "daily";
  };
}
