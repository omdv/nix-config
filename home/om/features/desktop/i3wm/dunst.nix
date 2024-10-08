{ config, ... }: let
  inherit (config.colorscheme) colors;
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
        frame_color = colors.primary_container;
        font = "${config.fontProfiles.monospace.family} 16";
      };

      urgency_normal = {
        background = colors.primary_container;
        foreground = colors.on_primary_container;
        timeout = 5;
      };
    };
  };
}
