{
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix

    ../common/global
    ../common/users/om

    ../common/optional/samba.nix
    ../common/optional/zfs.nix
    ../common/optional/k3s.nix
  ];

  networking = {
    hostId = "c6589261";
    hostName = "homelab";
    useDHCP = true;
    interfaces = {
      enp2s0 = {
        useDHCP = true;
        ipv4.addresses = [ {
          address = "192.168.1.100";
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
  polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.inhibit" && subject.user == "om") {
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
  };

  system.stateVersion = "23.05";
}
