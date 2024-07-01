# Build them using 'nix build .#example'
{pkgs, ...}:
{
  myjdk = pkgs.callPackage ./myjdk { };
}
