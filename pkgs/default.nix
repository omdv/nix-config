# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  dirac = pkgs.callPackage ./dirac {};
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent {};
  mirage-proxy = pkgs.callPackage ./mirage-proxy {};
  openspec = pkgs.callPackage ./openspec {};
  oh-my-pi = pkgs.callPackage ./oh-my-pi {};
}
