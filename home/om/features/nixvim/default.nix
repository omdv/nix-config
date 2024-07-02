{pkgs, ...}:
{
  imports = [ (import <nixpkgs> {}).nixvim ];

  # programs.mixvim = {
    # enable = true;
  # };
}
