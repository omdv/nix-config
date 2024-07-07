{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./global
    ./features/productivity
    ./features/desktop
    ./features/pass
    # ./features/nvim
    ./features/nixvim
  ];

  # borgmatic setup
  programs.borgmatic = {
    enable = true;
    backups = {
      borgbase = {
        location = {
          sourceDirectories = [ "/home/om" ];
          repositories = [ "ssh://ylc5axw6@ylc5axw6.repo.borgbase.com/./repo" ];
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
            ];
            exclude_if_present = [ ".nobackup" ];
            exclude_caches = true;
          };
        };
        storage = {
          encryptionPasscommand = "pass show backup/borgbase-arch";
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

  # borgmatic service
  services.borgmatic = {
    enable = true;
    frequency = "19:00";
  };
}
