# TODO try notmuch block
# TODO try rofi notification
# TODO number of failed services
# TODO colors from colorscheme

{ pkgs, config, ... }: let
  colors = {
    background = "#282a36";
    current = "#44475a";
    foreground = "#9ac4ff";
    foreground-alt = "#9ac4ff";
    comment = "#6272a4";
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
  };
in {
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
      iwSupport = true;
      githubSupport = true;
    };
    script = "polybar -q -r top &";
    config = {
      "bar/top" = {
        monitor = "eDP-1";
        width = "100%";
        height = "3%";
        radius = 0;
        line-size = 3;
        background = colors.background;
        foreground = colors.foreground;
        border-size = 0;
        border-color = colors.background;
        padding-left = 0;
        padding-right = 3;
        module-margin-left = 1;
        module-margin-right = 1;

        font-0 = "${config.fontProfiles.regular.family}:size=14;3";
        font-1 = "${config.fontProfiles.icons.family}:size=12;3";

        modules-left = "i3";
        modules-center = "date";
        modules-right = "cpu battery";
      };
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%Y-%m-%d";
        time = "%H:%M";
        label = "%date% %time%";
        label-font = 1;
      };
      "module/i3" = {
        type = "internal/i3";
        scroll-up = "i3wm-wsnext";
        scroll-down = "i3wm-wsprev";
        label-font = 1;
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 1;
        warn-percentage = 50;
        label = "CPU %percentage%%";
        label-warn-background = colors.red;
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "AC0";
        full-at = 100;
      };
    };
  };
}
