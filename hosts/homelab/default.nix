{
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/zfs.nix
    ../common/optional/k3s.nix

    ../common/users/om
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

  sops.secrets = {
    borg_passphrase = {
      sopsFile = ./secrets.yaml;
    };
  };

  system.stateVersion = "23.05";
}
