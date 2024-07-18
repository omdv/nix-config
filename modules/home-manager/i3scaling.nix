{
  lib,
  ...
}: let
  inherit (lib) types mkOption;
in {
  options.i3scaling = {
    dpi = mkOption {
      type = types.int;
      default = 1;
    };
    gtkfontsize = mkOption {
      type = types.int;
      default = 12;
    };
  };
}
