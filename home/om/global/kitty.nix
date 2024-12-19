{
  config,
  pkgs,
  lib,
  ...
}: let
  # inherit (config.colorscheme) colors harmonized;
  colors = {
    "background"= "#121318";
    "error"= "#ffb4ab";
    "error_container"= "#93000a";
    "inverse_on_surface"= "#303036";
    "inverse_primary"= "#4f5b92";
    "inverse_surface"= "#e3e1e9";
    "on_background"= "#e3e1e9";
    "on_error"= "#690005";
    "on_error_container"= "#ffdad6";
    "on_primary"= "#202c61";
    "on_primary_container"= "#dde1ff";
    "on_primary_fixed"= "#07164b";
    "on_primary_fixed_variant"= "#374379";
    "on_secondary"= "#2c2f42";
    "on_secondary_container"= "#dfe1f9";
    "on_secondary_fixed"= "#171b2c";
    "on_secondary_fixed_variant"= "#424659";
    "on_surface"= "#e3e1e9";
    "on_surface_variant"= "#c6c5d0";
    "on_tertiary"= "#44273e";
    "on_tertiary_container"= "#ffd7f3";
    "on_tertiary_fixed"= "#2c1229";
    "on_tertiary_fixed_variant"= "#5c3d56";
    "outline"= "#90909a";
    "outline_variant"= "#45464f";
    "primary"= "#b8c3ff";
    "primary_container"= "#374379";
    "primary_fixed"= "#dde1ff";
    "primary_fixed_dim"= "#b8c3ff";
    "scrim"= "#000000";
    "secondary"= "#c3c5dd";
    "secondary_container"= "#c3c5dd";
    "secondary_fixed"= "#dfe1f9";
    "secondary_fixed_dim"= "#c3c5dd";
    "shadow"= "#000000";
    "surface"= "#121318";
    "surface_bright"= "#38393f";
    "surface_container"= "#1f1f25";
    "surface_container_high"= "#292a2f";
    "surface_container_highest"= "#34343a";
    "surface_container_low"= "#1b1b21";
    "surface_container_lowest"= "#0d0e13";
    "surface_dim"= "#121318";
    "surface_variant"= "#45464f";
    "tertiary"= "#e4bad9";
    "tertiary_container"= "#5c3d56";
    "tertiary_fixed"= "#ffd7f3";
    "tertiary_fixed_dim"= "#e4bad9";
  };
  harmonized = {
    red = "#ff0000";
    green = "#00ff00";
    blue = "#0000ff";
    yellow = "#ffff00";
    orange = "#ffa500";
    purple = "#800080";
    pink = "#ffc0cb";
    brown = "#a52a2a";
    gray = "#808080";
    magenta = "#ff00ff";
    cyan = "#00ffff";
  } //colors;
in {
  home.packages = [
    (
      pkgs.writeShellScriptBin "xterm" ''
        ${lib.getExe config.programs.kitty.package} "$@"
      ''
    )
  ];
  # use ssh -M explicitly
  xdg.configFile."kitty/ssh.conf".text = ''
    share_connections no
  '';
  xdg.mimeApps = {
    associations.added = {
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
  };
  programs.kitty = {
    enable = true;
    font = {
      name = config.fontProfiles.monospace.family;
      size = 16;
    };
    keybindings = {
      "ctrl+enter" = "send_text normal clone-in-kitty --type os-window\\r";
    };
    settings = {
      editor = config.home.sessionVariables.EDITOR;
      scrollback_lines = 4000;
      scrollback_pager_history_size = 100000;
      window_padding_width = 15;

      # for nnn
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      enabled_layouts = "all";

      # colorscheme
      foreground = "${colors.on_surface}";
      background = "${colors.surface_container}";
      selection_background = "${colors.on_surface}";
      selection_foreground = "${colors.surface}";
      url_color = "${colors.on_surface_variant}";
      cursor = "${colors.on_surface}";
      active_border_color = "${colors.outline}";
      inactive_border_color = "${colors.surface_bright}";
      active_tab_background = "${colors.surface}";
      active_tab_foreground = "${colors.on_surface}";
      inactive_tab_background = "${colors.surface_bright}";
      inactive_tab_foreground = "${colors.on_surface_variant}";
      tab_bar_background = "${colors.surface_bright}";
      color0 = "${colors.surface}";
      color1 = "${harmonized.red}";
      color2 = "${harmonized.green}";
      color3 = "${harmonized.yellow}";
      color4 = "${harmonized.blue}";
      color5 = "${harmonized.magenta}";
      color6 = "${harmonized.cyan}";
      color7 = "${colors.on_surface}";
      color8 = "${colors.outline}";
      color9 = "${harmonized.red}";
      color10 = "${harmonized.green}";
      color11 = "${harmonized.yellow}";
      color12 = "${harmonized.blue}";
      color13 = "${harmonized.magenta}";
      color14 = "${harmonized.cyan}";
      color15 = "${colors.surface_dim}";
      color16 = "${harmonized.orange}";
      color17 = "${colors.error}";
      color18 = "${colors.surface_bright}";
      color19 = "${colors.surface_container}";
      color20 = "${colors.on_surface_variant}";
      color21 = "${colors.inverse_surface}";
    };
  };
}
