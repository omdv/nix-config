{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.matugen;
in {
  options.matugen = {
    enable = mkEnableOption "Matugen color scheme generation";

    colorHex = mkOption {
      type = types.str;
      description = "Hex color value for color scheme generation";
      example = "#ff0000";
    };

    outputPath = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.config/matugen";
      description = "Path to store generated color schemes";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.matugen ];

    home.activation.generateColorScheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.matugen}/bin/matugen color ${cfg.colorHex} -o ${cfg.outputPath}
    '';
  };
}
