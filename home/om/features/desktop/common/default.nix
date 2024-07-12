{pkgs, ...}: {
  imports = [
    ./firefox.nix
    ./fonts.nix
    ./qutebrowser.nix
  ];
}
