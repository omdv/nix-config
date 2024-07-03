{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix

    ../common/global
    ../common/users/om

    ../common/optional/gnome.nix
    ../common/optional/docker.nix
    ../common/optional/pipewire.nix
    ../common/optional/java.nix
    ../common/optional/btrfs.nix
  ];

  programs = {
    dconf.enable = true;
  };

  # Lid settings
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
  };

  networking = {
    hostName = "framework";
    networkmanager.enable = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "i686-linux"
    ];
  };

  # borgmatic
  services.borgmatic = {
    enable = true;
    config = {
      location = "/etc/borgmatic";
      config = ''
        location:
          source_directories:
            - /home/om/
          repositories:
            - ssh://ylc5axw6@ylc5axw6.repo.borgbase.com/./repo
          remote_path: borg1
          exclude_patterns:
            - '*.pyc'
            - /home/om/.cache
            - /home/om/.ssh
            - /home/om/.config/borg
            - '/home/om/*/node_modules/'
            - '/home/om/*/Trash/'
            - '/home/om/*/.venv/'
            - /home/om/Jts
            - /home/om/.asdf
            - /home/om/.gnupg
          exclude_if_present:
            - .nobackup
          exclude_caches: true
          storage:
            encryption_passcommand: pass show backup/borgbase-arch
          retention:
            keep_daily: 7
            keep_weekly: 4
            keep_monthly: 2
          ssh_command: ssh -i /home/om/.ssh/id_rsa
          borg_base_directory: /home/om/
      '';
    };
  };

  system.stateVersion = "23.05";
}
