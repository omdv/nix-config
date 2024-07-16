{
  pkgs,
  ...
}: {
  imports = [
    ./global

    ./features/desktop/gnome
    # ./features/desktop/hyprland

    ./features/cli
    ./features/nixvim
    ./features/productivity
    ./features/pass

    ./features/optional/quickemu.nix

    ./backup/framework.nix
  ];

  # Purple
  wallpaper = pkgs.wallpapers.towers-ice;
  colorscheme.type = "tonal-spot";

  # https://github.com/hyprwm/Hyprland/issues/4225
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
}
