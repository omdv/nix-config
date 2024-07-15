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

    ../common/optional/btrfs.nix
    # ../common/optional/gnome.nix
    # ../common/optional/greetd.nix

    ../common/optional/java.nix
    ../common/optional/libvirt.nix
    ../common/optional/pipewire.nix
    ../common/optional/poweropts.nix
    ../common/optional/quietboot.nix
    ../common/optional/vpn.nix
  ];

  specialisation = {
    gnome.configuration = {
      imports = [
        ../common/optional/gnome.nix
      ];
    programs.dconf.enable = true;
    };

    hyprland.configuration = {
      imports = [
        ../common/optional/greetd.nix
      ];
    };
  };

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
