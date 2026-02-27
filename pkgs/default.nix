# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  # myjdk = pkgs.callPackage ./myjdk { };
  rustledger = pkgs.callPackage ./rustledger { };
  rustfava = pkgs.callPackage ./rustfava { };
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent { };
}
