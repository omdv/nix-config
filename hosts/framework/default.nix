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
  ];

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

  system.stateVersion = "24.05";
}