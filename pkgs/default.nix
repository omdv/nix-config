# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent {};
  taskplane = pkgs.callPackage ./taskplane {};
  mirage-proxy = pkgs.callPackage ./mirage-proxy {};
}
