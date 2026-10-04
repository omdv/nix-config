{colors, ...}: {
  imports = [
    ./global
    ./features/cli
    ./backup/homelab.nix
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  colorscheme = colors.colorSchemes.solarized-dark;
}
