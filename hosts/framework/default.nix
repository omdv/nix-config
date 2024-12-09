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

    ../common/optional/i3wm.nix

    ../common/optional/btrfs.nix
    ../common/optional/docker.nix
    ../common/optional/java.nix
    ../common/optional/libvirt.nix
    ../common/optional/pipewire.nix
    ../common/optional/light.nix
    ../common/optional/poweropts.nix
    ../common/optional/platformio.nix
    ../common/optional/steam.nix
    ../common/optional/quietboot.nix
    ../common/optional/vpn.nix
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

  sops.secrets = {
    backup_passphrase = {
      owner = "om";
      group = "wheel";
      mode = "0400";
      sopsFile = ./secrets.yaml;
      path = "/run/user-secrets/backup-passphrase";
    };
  };

  hardware.opengl.enable = true;

  system.stateVersion = "23.05";
}
