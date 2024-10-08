{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.colorscheme) colors harmonized;
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
