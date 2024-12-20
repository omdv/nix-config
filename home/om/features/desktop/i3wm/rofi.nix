{ config, lib, ... }: let
  colors = config.colorscheme.palette;
in {
  programs.rofi = {
    enable = true;
    terminal = lib.getExe config.programs.kitty.package;
    theme = "${config.xdg.configHome}/rofi/theme.rasi";
    font = "${config.fontProfiles.monospace.family} 16";
  };

  xdg.configFile."rofi/theme.rasi".source = ./rofi-theme.rasi;
  xdg.configFile."rofi/colors.rasi".text = ''
  * {
      background: #${colors.base02};
      background-alt: #${colors.base01};
      foreground: #${colors.base06};
      selected: #${colors.base06};
      active: #${colors.base06};
      urgent: #${colors.base08};
  }
  '';
}
