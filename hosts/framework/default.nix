{
  pkgs,
  lib,
  inputs,
  ...
}: let
  mkSecret = import ../../lib/mkSecret.nix { inherit lib; };
in {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ./networking.nix

    ../common/global
    ../common/users/om

    ../common/optional/xserver.nix
    ../common/optional/i3wm.nix

    ../common/optional/btrfs.nix
    ../common/optional/java.nix
    ../common/optional/libvirt.nix
    ../common/optional/light.nix
    ../common/optional/ollama.nix
    ../common/optional/pipewire.nix
    ../common/optional/poweropts.nix
    ../common/optional/printers.nix
    ../common/optional/quietboot.nix
    ../common/optional/smartd.nix
    ../common/optional/steam.nix
    ../common/optional/virtualisation.nix
    ../common/optional/vpn.nix
  ];

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
    backup_passphrase = mkSecret { name = "backup_passphrase"; sopsFile = ./secrets.yaml; };
    ntfy_system_topic = mkSecret { name = "ntfy_system_topic"; sopsFile = ./secrets.yaml; };
  };

  hardware.graphics.enable = true;

  system.stateVersion = "23.05";
}
