# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  # myjdk = pkgs.callPackage ./myjdk { };

}
