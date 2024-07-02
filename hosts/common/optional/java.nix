{pkgs, ...}:
{
  nixpkgs.config = {
    allowUnfree = true;
    oraclejdk.accept_license = true;
  };

  programs.java = {
    enable = true;
    package = pkgs.oraclejdk;
  };
}
