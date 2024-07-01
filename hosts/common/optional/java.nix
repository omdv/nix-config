{pkgs, ...}:
let
  myjava = pkgs.myjava;
in
{
  nixpkgs.config.allowUnfree = true;
  programs.java = {
    enable = true;
    package = myjava;
  };
}
