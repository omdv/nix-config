{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
      inputs.nix-colors.homeManagerModules.colorscheme

    ./global
    ./features/productivity
    ./features/desktop/gnome
    ./features/pass
    ./features/nixvim

    ./backup/framework.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes.dracula;

  monitors = [
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      workspace = "1";
      primary = true;
    }
  ];
}
