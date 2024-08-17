{
  pkgs,
  lib,
  config,
  outputs,
  ...
}: {
  imports = [
    ./fonts.nix
  ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "om";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
  };

  nix.package = pkgs.nix;
}
