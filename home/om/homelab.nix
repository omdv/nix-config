{
  imports = [
    ./global

    ./features/cli
    ./features/nixvim
    ./features/pass

    ./backup/homelab.nix
  ];

  # colorscheme
  colorscheme.source = "#e05b18";
  colorscheme.type = "tonal-spot";
}
