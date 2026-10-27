{pkgs, ...}: {
  imports = [
    ./brave.nix
    ./cursor.nix
    ./fonts.nix
    ./firefox.nix
    ./gtk.nix
    ./keyring.nix
    ./kitty.nix
    ./qutebrowser.nix
    ./terminal-desktop-entries.nix
    ./zellij-helpers.nix
    ./pavucontrol.nix
    ./xdg.nix
  ];

  home.packages = [
    pkgs.appimage-run
    pkgs.feh
    pkgs.maim
    pkgs.qgis
    pkgs.simplescreenrecorder
    pkgs.steam-run
  ];
}
