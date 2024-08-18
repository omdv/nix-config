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

  # colorscheme
  colorscheme.source = "#e05b18";
  colorscheme.type = "tonal-spot";
}
