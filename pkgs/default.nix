# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  rustledger = pkgs.callPackage ./rustledger {};
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent {};
  mirage-proxy = pkgs.callPackage ./mirage-proxy {};
}
