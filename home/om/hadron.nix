{colors, ...}: {
  imports = [
    ./global

    ./features/desktop/common
    ./features/desktop/gnome

    ./features/cli
    ./features/development

    ./features/optional/minecraft-clj.nix
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  colorscheme = colors.colorSchemes.gruvbox-dark-soft;
}
