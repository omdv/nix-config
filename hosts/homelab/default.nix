{
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix

    ../common/global
    ../common/users/om

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

  # open ports for other k3s apps
  networking.firewall.allowedTCPPorts = [
    445 #samba
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

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
