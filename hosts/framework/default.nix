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
    ../common/optional/java.nix
    ../common/optional/libvirt.nix
    ../common/optional/pipewire.nix
    ../common/optional/light.nix
    ../common/optional/poweropts.nix
    ../common/optional/steam.nix
    ../common/optional/quietboot.nix
    ../common/optional/vpn.nix
  ];

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

  # sops.secrets = {
  #   email_fastmail_address = {
  #     owner = "om";
  #     group = "wheel";
  #     mode = "0400";
  #     sopsFile = ./secrets.yaml;
  #     path = "/run/user-secrets/email-fastmail-address";
  #   };
  #   # email_gmail_address = {
  #   #   owner = "om";
  #   #   group = "wheel";
  #   #   mode = "0400";
  #   #   sopsFile = ./secrets.yaml;
  #   #   path = "/run/user-secrets/email-gmail-address";
  #   # };
  # };

  hardware.opengl.enable = true;

  system.stateVersion = "23.05";
}
