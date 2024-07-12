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
}
