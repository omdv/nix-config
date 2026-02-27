# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  # myjdk = pkgs.callPackage ./myjdk { };
  rustledger = pkgs.callPackage ./rustledger { };
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent { };
  oh-my-pi = pkgs.callPackage ./oh-my-pi { };
}
