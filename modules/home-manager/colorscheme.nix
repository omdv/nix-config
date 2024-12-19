{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;
in {
  options.colorScheme = mkOption {
    type = types.attrs;
  };
}
