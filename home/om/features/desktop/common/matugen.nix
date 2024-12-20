{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    matugen
  ];
  # matugen = {
  #   enable = true;
  #   colorHex = "#ff0000";
  #   outputPath = "${config.home.homeDirectory}/.config/matugen";
  # };
}
