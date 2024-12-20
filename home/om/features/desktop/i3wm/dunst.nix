{ config, ... }: let
  colors = config.colorscheme.palette;
in {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x60";
        origin = "top-right";
        transparency = 5;
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
