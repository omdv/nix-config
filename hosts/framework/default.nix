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
    # ../common/optional/gnome.nix31
    # ../common/optional/hyprland.nix
    # ../common/optional/greetd.nix1

    ../common/optional/btrfs.nix
    ../common/optional/java.nix
    ../common/optional/libvirt.nix
    ../common/optional/pipewire.nix
    ../common/optional/light.nix
    ../common/optional/poweropts.nix
    ../common/optional/quietboot.nix
    ../common/optional/vpn.nix
  ];

  # specialisation = {
  #   hypr.configuration = {
  #     imports = [
  #       ../common/optional/hyprland.nix
  #     ];
  #   };
  #   i3wm.configuration = {
  #     imports = [
  #       ../common/optional/i3wm.nix
  #     ];
  #   };
  # };

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

  hardware.opengl.enable = true;

  system.stateVersion = "23.05";
}
