{
  pkgs,
  ...
}: {
  imports = [
    ./global

    ./features/desktop/i3wm

    ./features/cli
    ./features/nixvim
    ./features/productivity
    ./features/pass

    ./features/optional/quickemu.nix
    ./features/optional/mpv.nix
    ./features/optional/zathura.nix
    ./features/optional/steam.nix

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
      scale = 1.0;
    }
  ];

  i3scaling = {
    dpi = 144; #96 is 1.0 scale
    gtkFontSize = 12;
    cursorSize = 36;
  };
}
