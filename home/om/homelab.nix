{ colors, ... }: {
  imports = [
    ./global

    ./features/cli
    ./features/nixvim
    ./features/pass

    ./backup/homelab.nix
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  colorscheme = colors.colorSchemes.solarized-dark;
}
