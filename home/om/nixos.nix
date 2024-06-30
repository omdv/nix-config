{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./global
    ./features/cli
  ];
}
