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
    gtkFontSize = mkOption {
      type = types.int;
      default = 12;
    };
    cursorSize = mkOption {
      type = types.int;
      default = 18;
    };
  };
}
