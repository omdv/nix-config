{colors, ...}: {
  imports = [
    ./global

    ./features/cli
    ./features/nixvim
    ./features/pass
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  colorscheme = colors.colorSchemes.solarized-dark;
}
