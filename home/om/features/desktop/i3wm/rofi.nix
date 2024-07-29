# TODO rice rofi
{ config, lib, ... }: {
  programs.rofi = {
    enable = true;
    terminal = lib.getExe config.programs.kitty.package;
    # theme = "glue_pro_blue";
    theme = "${config.xdg.configHome}/rofi/theme.rasi";
    font = "${config.fontProfiles.monospace.family} 14";
  };

  xdg.configFile."rofi/theme.rasi".source = ./rofi/theme.rasi;
  xdg.configFile."rofi/colors.rasi".source = ./rofi/colors.rasi;
}
