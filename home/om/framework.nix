{ config, colors, ... }: {
  imports = [
    ./global

    ./features/desktop/common
    ./features/desktop/i3wm

    ./features/cli
    ./features/nixvim
    ./features/productivity
    ./features/pass

    ./features/optional/mpv.nix
    ./features/optional/pyradio.nix
    ./features/optional/quickemu.nix
    ./features/optional/zathura.nix
    ./features/optional/zotero.nix

    ./features/gaming/wesnoth.nix
    ./features/gaming/cdda.nix

    ./backup/framework.nix
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  colorscheme = colors.colorSchemes.material;

  # colors = {
  #   "background"= "#121318";
  #   "error"= "#ffb4ab";
  #   "error_container"= "#93000a";
  #   "inverse_on_surface"= "#303036";
  #   "inverse_primary"= "#4f5b92";
  #   "inverse_surface"= "#e3e1e9";
  #   "on_background"= "#e3e1e9";
  #   "on_error"= "#690005";
  #   "on_error_container"= "#ffdad6";
  #   "on_primary"= "#202c61";
  #   "on_primary_container"= "#dde1ff";
  #   "on_primary_fixed"= "#07164b";
  #   "on_primary_fixed_variant"= "#374379";
  #   "on_secondary"= "#2c2f42";
  #   "on_secondary_container"= "#dfe1f9";
  #   "on_secondary_fixed"= "#171b2c";
  #   "on_secondary_fixed_variant"= "#424659";
  #   "on_surface"= "#e3e1e9";
  #   "on_surface_variant"= "#c6c5d0";
  #   "on_tertiary"= "#44273e";
  #   "on_tertiary_container"= "#ffd7f3";
  #   "on_tertiary_fixed"= "#2c1229";
  #   "on_tertiary_fixed_variant"= "#5c3d56";
  #   "outline"= "#90909a";
  #   "outline_variant"= "#45464f";
  #   "primary"= "#b8c3ff";
  #   "primary_container"= "#374379";
  #   "primary_fixed"= "#dde1ff";
  #   "primary_fixed_dim"= "#b8c3ff";
  #   "scrim"= "#000000";
  #   "secondary"= "#c3c5dd";
  #   "secondary_container"= "#c3c5dd";
  #   "secondary_fixed"= "#dfe1f9";
  #   "secondary_fixed_dim"= "#c3c5dd";
  #   "shadow"= "#000000";
  #   "surface"= "#121318";
  #   "surface_bright"= "#38393f";
  #   "surface_container"= "#1f1f25";
  #   "surface_container_high"= "#292a2f";
  #   "surface_container_highest"= "#34343a";
  #   "surface_container_low"= "#1b1b21";
  #   "surface_container_lowest"= "#0d0e13";
  #   "surface_dim"= "#121318";
  #   "surface_variant"= "#45464f";
  #   "tertiary"= "#e4bad9";
  #   "tertiary_container"= "#5c3d56";
  #   "tertiary_fixed"= "#ffd7f3";
  #   "tertiary_fixed_dim"= "#e4bad9";
  # };
  # harmonized = {
  #   red = "#ff0000";
  #   green = "#00ff00";
  #   blue = "#0000ff";
  #   yellow = "#ffff00";
  #   orange = "#ffa500";
  #   purple = "#800080";
  #   pink = "#ffc0cb";
  #   brown = "#a52a2a";
  #   gray = "#808080";
  #   magenta = "#ff00ff";
  #   cyan = "#00ffff";
  # } //colors;

  # Base16 Color Scheme Convention:
  # name: "Catppuccin Frappe"
  # base00 = "#303446"; # default background
  # base01 = "#292c3c"; # lighter background (status bars, line numbers, folding marks)
  # base02 = "#414559"; # selection background
  # base03 = "#51576d"; # comments, invisibles, line highlighting
  # base04 = "#626880"; # dark foreground (status bars)
  # base05 = "#c6d0f5"; # default foreground, caret, delimiters, operators
  # base06 = "#f2d5cf"; # light foreground (not often used)
  # base07 = "#babbf1"; # light background (not often used)
  # base08 = "#e78284"; # variables, XML tags, markup link text, markup lists, diff deleted
  # base09 = "#ef9f76"; # integers, boolean, constants, XML attributes, markup link url
  # base0A = "#e5c890"; # classes, markup bold, search text background
  # base0B = "#a6d189"; # strings, inherited class, markup code, diff inserted
  # base0C = "#81c8be"; # support, regular expressions, escape characters, markup quotes
  # base0D = "#8caaee"; # functions, methods, attribute IDs, headings
  # base0E = "#ca9ee6"; # keywords, storage, selector, markup italic, diff changed
  # base0F = "#eebebe"; # deprecated, opening/closing embedded language tags

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

  monitors = [
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      workspace = "1";
      primary = true;
      scale = 1.0;
    }
  ];

  # sops-nix
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets.fastmail_password = { sopsFile = ./secrets.yaml; };
    secrets.gmail_password = { sopsFile = ./secrets.yaml; };
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  i3scaling = {
    dpi = 144; #96 is 1.0 scale
    gtkFontSize = 12;
    cursorSize = 36;
  };
}
