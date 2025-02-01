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
    ./features/optional/telegram.nix
    ./features/optional/zathura.nix
    ./features/optional/zotero.nix

    ./features/gaming/wesnoth.nix
    ./features/gaming/cdda.nix
    ./features/gaming/discord.nix

    ./backup/framework.nix
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  # Base16 Color Scheme Convention:
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
  colorscheme = colors.colorSchemes.material;

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
