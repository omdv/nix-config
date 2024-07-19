# TODO try notmuch block
# TODO try rofi notification
# TODO number of failed services

{ pkgs, config, ... }: let
  inherit (config.colorscheme) colors harmonized;
  # matugen color -t scheme-tonal-spot hex "#2B3975" --show-colors

  # colors = {
  #   "background"= "#121318";
  #   "error"= "#ffb4ab";
  #   "error_container"= "#93000a";
  #   "inverse_on_surface"= "#303036";
  #   "inverse_primary"= "#4f5b92";
  #   "inverse_surface"= "#e3e1e9";
  #   "on_background"= "#e3e1e9";
  #   "on_error"= "#690005";
  #   "on_error_container"= "#ffdad6";
  #   "on_primary"= "#202c61";
  #   "on_primary_container"= "#dde1ff";
  #   "on_primary_fixed"= "#07164b";
  #   "on_primary_fixed_variant"= "#374379";
  #   "on_secondary"= "#2c2f42";
  #   "on_secondary_container"= "#dfe1f9";
  #   "on_secondary_fixed"= "#171b2c";
  #   "on_secondary_fixed_variant"= "#424659";
  #   "on_surface"= "#e3e1e9";
  #   "on_surface_variant"= "#c6c5d0";
  #   "on_tertiary"= "#44273e";
  #   "on_tertiary_container"= "#ffd7f3";
  #   "on_tertiary_fixed"= "#2c1229";
  #   "on_tertiary_fixed_variant"= "#5c3d56";
  #   "outline"= "#90909a";
  #   "outline_variant"= "#45464f";
  #   "primary"= "#b8c3ff";
  #   "primary_container"= "#374379";
  #   "primary_fixed"= "#dde1ff";
  #   "primary_fixed_dim"= "#b8c3ff";
  #   "scrim"= "#000000";
  #   "secondary"= "#c3c5dd";
  #   "secondary_container"= "#c3c5dd";
  #   "secondary_fixed"= "#dfe1f9";
  #   "secondary_fixed_dim"= "#c3c5dd";
  #   "shadow"= "#000000";
  #   "surface"= "#121318";
  #   "surface_bright"= "#38393f";
  #   "surface_container"= "#1f1f25";
  #   "surface_container_high"= "#292a2f";
  #   "surface_container_highest"= "#34343a";
  #   "surface_container_low"= "#1b1b21";
  #   "surface_container_lowest"= "#0d0e13";
  #   "surface_dim"= "#121318";
  #   "surface_variant"= "#45464f";
  #   "tertiary"= "#e4bad9";
  #   "tertiary_container"= "#5c3d56";
  #   "tertiary_fixed"= "#ffd7f3";
  #   "tertiary_fixed_dim"= "#e4bad9"
  # };
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
        background = colors.surface;
        foreground = colors.secondary;
        border-size = 0;
        border-color = colors.background;
        padding-left = 0;
        padding-right = 3;
        module-margin-left = 1;
        module-margin-right = 1;

        font-0 = "${config.fontProfiles.regular.family}:size=14;3";
        font-1 = "${config.fontProfiles.icons.family}:size=24;3";

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
      "module/cpu" = {
        type = "internal/cpu";
        interval = 1;
        warn-percentage = 5;
        label = "CPU %percentage%%";
        format-warn-background = colors.error;
        label-font = 1;
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "AC0";
        full-at = 100;
        label-font = 1;
      };
      "module/i3" = {
        type = "internal/i3";
        format = "<label-state> <label-mode>";
        index-sort = true;
        wrapping-scroll = true;
        enable-click = true;
        pin-workspaces = true;
        fuzzy-match = true;
        label-font = 2;

        ws-icon-0 = "1;󰎤";
        ws-icon-1 = "2;󰎧";
        ws-icon-2 = "3;󰎪";
        ws-icon-3 = "4;󰎭";
        ws-icon-4 = "5;󰎱";
        ws-icon-5 = "6;󰎳";
        ws-icon-6 = "7;󰎶";
        ws-icon-7 = "8;󰎹";
        ws-icon-8 = "9;󰎼";
        ws-icon-9 = "10;󰽽";

        format-background = colors.surface;

        label-mode = "%mode%";
        label-mode-padding = 2;

        label-unfocused = "%icon%";
        label-unfocused-padding = 2;

        # focused button
        label-focused = "%icon%";
        label-focused-padding = 3;
        label-focused-underline = colors.secondary;
        label-focused-foreground = "#e3e1e9";
        label-focused-background = "#38393f";

        label-visible = "%icon%";
        label-visible-padding = 2;

        label-urgent = "%index%";
        label-urgent-padding = 2;

      };
    };
  };
}
