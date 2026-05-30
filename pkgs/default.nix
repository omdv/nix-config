# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  openspec = pkgs.callPackage ./openspec {};
  oh-my-pi = pkgs.callPackage ./oh-my-pi {};
}
