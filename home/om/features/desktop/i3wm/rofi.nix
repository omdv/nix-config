{ config, lib, ... }: let
  inherit (config.colorscheme) colors;
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
      background: ${colors.surface_container_high};
      background-alt: ${colors.surface_container_highest};
      foreground: ${colors.primary};
      selected: ${colors.on_primary_container};
      active: ${colors.inverse_primary};
      urgent: ${colors.error};
  }
  '';
}
