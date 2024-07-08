{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
      inputs.nix-colors.homeManagerModules.colorscheme

    ../global
    ../features/productivity
    ../features/desktop
    ../features/pass
    ../features/nixvim

    ./borgmatic.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes.dracula;
}
