# TODO rice rofi
{ config, lib, ... }: {
  programs.rofi = {
    enable = true;
    terminal = lib.getExe config.programs.kitty.package;
    theme = "glue_pro_blue";
  };
}
