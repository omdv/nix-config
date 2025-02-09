{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix

    ../common/global
    ../common/users/om

    ../common/optional/k3s.nix
    ../common/optional/samba.nix
    ../common/optional/smartd.nix
    ../common/optional/zfs.nix
  ];

  networking = {
    hostId = "c6589261";
    hostName = "homelab";
    useDHCP = true;
    interfaces = {
      enp2s0 = {
        useDHCP = true;
        ipv4.addresses = [ {
          address = "192.168.1.98";
          prefixLength = 24;
        } ];
      };
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # enable lingering for systemd services
  users.users.om.linger = true;

  # allow om to inhibit systemd services
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ([
          "org.freedesktop.login1.inhibit-block-sleep",
          "org.freedesktop.login1.inhibit-block-idle",
          "org.freedesktop.login1.inhibit-block-shutdown",
        ].indexOf(action.id) >= 0 &&
        subject.user == "${config.users.users.om.name}") {
        return polkit.Result.YES;
      }
    });
  '';

  sops.secrets = {
    backup_passphrase = {
      owner = "om";
      group = "wheel";
      mode = "0400";
      sopsFile = ./secrets.yaml;
      path = "/run/user-secrets/backup-passphrase";
    };
    ntfy_system_topic = {
      owner = "om";
      group = "wheel";
      mode = "0400";
      sopsFile = ./secrets.yaml;
      path = "/run/user-secrets/ntfy-system-topic";
    };
  };

  system.stateVersion = "23.05";
}
