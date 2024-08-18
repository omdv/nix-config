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
    networkmanager.enable = true;
    interfaces = {
      enp2s0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.1.100";
          prefixLength = 24;
        } ];
      };
    };
    defaultGateway = "192.168.1.1";
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "23.05";
}
