{
  pkgs,
  ...
}: {
  imports = [
    ./global

    ./features/cli
    ./features/nixvim
    ./features/pass
  ];

  # Purple
  wallpaper = pkgs.wallpapers.towers-ice;
  colorscheme.type = "tonal-spot";
}
