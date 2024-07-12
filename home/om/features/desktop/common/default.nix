{pkgs, ...}: {
  imports = [
    ./firefox.nix
    ./fonts.nix
    ./kitty.nix
  ];
}
