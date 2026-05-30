# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  mirage-proxy = pkgs.callPackage ./mirage-proxy {};
  openspec = pkgs.callPackage ./openspec {};
  oh-my-pi = pkgs.callPackage ./oh-my-pi {};
}
