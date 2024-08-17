{
  pkgs,
  ...
}: {
  imports = [
    ./global

    ./features/cli
    ./features/nixvim
  ];

  # Purple
  wallpaper = pkgs.wallpapers.towers-ice;
  colorscheme.type = "tonal-spot";
}
