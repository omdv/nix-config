# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  myjava = pkgs.callPackage ./jdk22 { };
}
