{pkgs, ...}:
{
  nixpkgs.config.allowUnfree = true;
  programs.java = {
    enable = true;
    package = pkgs.myjdk;
  };
}
