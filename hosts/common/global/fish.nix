{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    vendor = {
      completions.enable = true;
      config.enable = true;
      functions.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    fishPlugins.done
    # fishPlugins.fzf-fish
    # fzf
    fishPlugins.grc
    grc
  ];
}
