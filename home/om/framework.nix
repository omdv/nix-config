{
  pkgs,
  ...
}: {
  imports = [
    ./global


    ./features/desktop/common
    ./features/desktop/gnome
    ./features/desktop/hyprland

    ./features/productivity
    ./features/pass

    ./features/optional/quickemu.nix

    ./backup/framework.nix
  ];

  # Purple
  wallpaper = pkgs.wallpapers.towers-ice;
  colorscheme.type = "tonal-spot";

  monitors = [
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      workspace = "1";
      primary = true;
    }
  ];
}
