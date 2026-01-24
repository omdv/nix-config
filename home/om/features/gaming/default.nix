{pkgs-unstable, ...}: {
  home.packages = with pkgs-unstable; [
    # brogue # roguelike
    cataclysm-dda # roguelike
    openttd # open-source clone of Transport Tycoon Deluxe
    openrct2 # open-source clone of RollerCoaster Tycoon 2
    # vcmi # client for VCMI engine - Heroes of Might and Magic 3
    # pkgs.wesnoth # turn-based strategy game
  ];
}
