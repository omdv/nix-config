{
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/zfs.nix

    ../common/users/om
  ];

  networking = {
    hostId = "c6589261";
    hostName = "homelab";
    networkmanager.enable = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    # binfmt.emulatedSystems = [
      # "aarch64-linux"
      # "i686-linux"
    # ];
  };

  system.stateVersion = "23.05";
}
