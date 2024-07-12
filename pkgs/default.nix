# Build them using 'nix build .#example'
{pkgs, ...}:
{
  myjdk = pkgs.callPackage ./myjdk { };
  pass-wofi = pkgs.callPackage ./pass-wofi { };
}
