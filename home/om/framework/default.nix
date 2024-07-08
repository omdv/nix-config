{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ../global
    ../features/productivity
    ../features/desktop
    ../features/pass
    ../features/nixvim

    ./borgmatic.nix
  ];
}