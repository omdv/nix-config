# Build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent {};
  taskplane = pkgs.callPackage ./taskplane {};
  context-mode = pkgs.callPackage ./context-mode {};
  mirage-proxy = pkgs.callPackage ./mirage-proxy {};
  jjcai = pkgs.callPackage ./jjcai { aichat = pkgs.unstable.aichat; };
}
