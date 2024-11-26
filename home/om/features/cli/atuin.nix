# https://docs.atuin.sh/configuration/config/
{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      # "--disable-up-arrow"
      # "--disable-ctrl-r"
    ];
    settings = {
    enter_accept = "false";
    };
  };
}
