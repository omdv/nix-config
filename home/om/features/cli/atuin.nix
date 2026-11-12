# https://docs.atuin.sh/configuration/config/
{pkgs, ...}: {
  programs.atuin = {
    enable = true;
    package = pkgs.unstable.atuin;
    enableFishIntegration = true;
    flags = [
      # "--disable-up-arrow"
      # "--disable-ctrl-r"
    ];
    settings = {
      enter_accept = false;
    };
  };
}
