{pkgs, ...}: {
  home.packages = with pkgs; [
    brogue # roguelike
    cataclysm-dda # roguelike
    mudlet # client for MUDs
    openttd # open-source clone of Transport Tycoon Deluxe
    vcmi # client for VCMI engine - Heroes of Might and Magic 3
    wesnoth # turn-based strategy game
  ];
}
