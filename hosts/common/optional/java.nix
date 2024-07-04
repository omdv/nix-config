{pkgs, ...}:
{
  programs.java = {
    enable = true;
    # package = pkgs.myjdk;
    package = pkgs.openjdk;
  };
}
