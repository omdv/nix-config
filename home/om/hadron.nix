{colors, ...}: {
  imports = [
    ./global

    ./features/desktop/common
    ./features/desktop/i3wm

    ./features/cli
    ./features/nixvim
    ./features/pass

    ./features/optional/minecraft-clj.nix
  ];

  # nix-colors colorscheme
  # https://github.com/tinted-theming/schemes
  colorscheme = colors.colorSchemes.gruvbox-dark-soft;
}
