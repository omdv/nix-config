{
  config,
  pkgs,
  lib,
  ...
}: let
  colors = config.colorscheme.palette;
  # name = "Gruvbox dark, soft";
  # base00 = "#32302f"; # default background
  # base01 = "#3c3836"; # lighter background (status bars, line numbers, folding marks)
  # base02 = "#504945"; # selection background
  # base03 = "#665c54"; # comments, invisibles, line highlighting
  # base04 = "#bdae93"; # dark foreground (status bars)
  # base05 = "#d5c4a1"; # default foreground, caret, delimiters, operators
  # base06 = "#ebdbb2"; # light foreground (not often used)
  # base07 = "#fbf1c7"; # light background (not often used)
  # base08 = "#fb4934"; # variables, XML tags, markup link text, markup lists, diff deleted
  # base09 = "#fe8019"; # integers, boolean, constants, XML attributes, markup link url
  # base0A = "#fabd2f"; # classes, markup bold, search text background
  # base0B = "#b8bb26"; # strings, inherited class, markup code, diff inserted
  # base0C = "#8ec07c"; # support, regular expressions, escape characters, markup quotes
  # base0D = "#83a598"; # functions, methods, attribute IDs, headings
  # base0E = "#d3869b"; # keywords, storage, selector, markup italic, diff changed
  # base0F = "#d65d0e"; # deprecated, opening/closing embedded language tags

  # name = "Material";
  # base00 = "#263238"; # default background
  # base01 = "#2E3C43"; # lighter background (status bars, line numbers, folding marks)
  # base02 = "#314549"; # selection background
  # base03 = "#546E7A"; # comments, invisibles, line highlighting
  # base04 = "#B2CCD6"; # dark foreground (status bars)
  # base05 = "#EEFFFF"; # default foreground, caret, delimiters, operators
  # base06 = "#EEFFFF"; # light foreground (not often used)
  # base07 = "#FFFFFF"; # light background (not often used)
  # base08 = "#F07178"; # variables, XML tags, markup link text, markup lists, diff deleted
  # base09 = "#F78C6C"; # integers, boolean, constants, XML attributes, markup link url
  # base0A = "#FFCB6B"; # classes, markup bold, search text background
  # base0B = "#C3E88D"; # strings, inherited class, markup code, diff inserted
  # base0C = "#89DDFF"; # support, regular expressions, escape characters, markup quotes
  # base0D = "#82AAFF"; # functions, methods, attribute IDs, headings
  # base0E = "#C792EA"; # keywords, storage, selector, markup italic, diff changed
  # base0F = "#FF5370"; # deprecated, opening/closing embedded language tags
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
      foreground = "#${colors.base05}";
      background = "#${colors.base00}";
      selection_background = "#${colors.base05}";
      selection_foreground = "#${colors.base00}";
      url_color = "#${colors.base04}";
      cursor = "#${colors.base05}";
      active_border_color = "#${colors.base03}";
      inactive_border_color = "#${colors.base01}";
      active_tab_background = "#${colors.base00}";
      active_tab_foreground = "#${colors.base05}";
      inactive_tab_background = "#${colors.base01}";
      inactive_tab_foreground = "#${colors.base04}";
      tab_bar_background = "#${colors.base01}";

      # normal
      color0 = "#${colors.base00}";
      color1 = "#${colors.base08}";
      color2 = "#${colors.base0B}";
      color3 = "#${colors.base0A}";
      color4 = "#${colors.base0D}";
      color5 = "#${colors.base0E}";
      color6 = "#${colors.base0C}";
      color7 = "#${colors.base05}";

      # bright
      color8 = "#${colors.base03}";
      color9 = "#${colors.base09}";
      color10 = "#${colors.base01}";
      color11 = "#${colors.base02}";
      color12 = "#${colors.base04}";
      color13 = "#${colors.base06}";
      color14 = "#${colors.base0F}";
      color15 = "#${colors.base07}";
    };
  };
}
