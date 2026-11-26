{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    ./unkernel.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    overlays = outputs.lib.orderedOverlays;
  };

  networking = {
    hostName = "emulator";
    useDHCP = false;
    enableIPv6 = false;
    firewall.enable = false;
  };
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.05";

  documentation.enable = false;
  nix = {
    channel.enable = false;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  users.users.om = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    initialHashedPassword = "!";
  };
  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
      colors = inputs.nix-colors;
      hostName = "emulator";
      flakePath = "/home/om/nix-config";
    };
    sharedModules =
      [inputs.nix-colors.homeManagerModules.default]
      ++ builtins.attrValues (import ../../modules/home-manager);
    users.om = import ../../home/om/emulator.nix;
  };
}
