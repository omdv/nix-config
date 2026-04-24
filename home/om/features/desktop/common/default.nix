{pkgs, ...}: {
  imports = [
    ./brave.nix
    ./cursor.nix
    ./firefox.nix
    ./gtk.nix
    ./keyring.nix
    ./pavucontrol.nix
    ./xdg.nix
  ];

  home.packages = [
    pkgs.appimage-run
    pkgs.steam-run
  ];
}
