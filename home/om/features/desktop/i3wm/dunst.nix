{ config, ... }: let
  colors = config.colorscheme.palette;
in {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 100;
        offset = "30x100";
        origin = "top-right";
        transparency = 20;
        frame_color = "#${colors.base00}";
        font = "${config.fontProfiles.monospace.family} 16";
      };

      urgency_normal = {
        background = "#${colors.base01}";
        foreground = "#${colors.base06}";
        timeout = 5;
      };
    };
  };
}
