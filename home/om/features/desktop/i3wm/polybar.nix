{ pkgs, config, lib, ... }: let
  inherit (config.colorscheme) colors harmonized;

  mapStrings = f: xs: lib.map (x: f x) xs;
  commonDeps = with pkgs; [coreutils gnugrep];
  mkScriptFromFile = {
    name ? "script",
    deps ? [],
    scriptFile ? "",
    args ? [],
  }:
    let
      quotedArgs = lib.concatStringsSep " " (mapStrings (arg: "\"${arg}\"") args);
    in
      lib.getExe (pkgs.writeShellApplication {
        inherit name;
        text = builtins.readFile scriptFile; # or just text=cmd
        runtimeInputs = commonDeps ++ deps;
      })  + " " + quotedArgs;
in {
  # service itself
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = false;
      iwSupport = false;
      githubSupport = false;
    };
    script = "polybar -q -r top &";
    config = {
      "bar/root" = {
        monitor = "eDP-1";
        override-redirect = true;
        wm-restack = "i3";
        height = "3%";
        radius = 0;
        bottom = false;

        background = colors.surface_container;
        foreground = colors.secondary;
        border-size = "1pt";
        border-color = colors.surface_container;
        padding-left = 0;
        padding-right = 3;
        module-margin-left = 1;
        module-margin-right = 1;

        font-0 = "${config.fontProfiles.regular.family}:size=14;3";
        font-1 = "${config.fontProfiles.icons.family}:size=24;3";
        font-2 = "${config.fontProfiles.icons.family}:size=16;3";

      };
      "bar/top" = {
        "inherit" = "bar/root";
        width = "100%";
        offset-y = 0;
        modules-left = "i3";
        modules-center = "date";
        modules-right = "cpu mem temp xkeyboard audio wlan email battery";
      };
      "module/date" = {
        type = "internal/date";
        interval = 60;
        date = "%Y-%m-%d";
        time = "%H:%M";
        label = "%date% %time%";
        label-font = 1;
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 1;
        warn-percentage = 90;
        label-font = 1;
        format = "<label>";
        format-warn = "%{F${harmonized.red}} <label-warn> %{F-}";
        label = "%{T3} %{T-}%percentage%%";
        label-warn = "%{T3} %{T-}%percentage%%";
      };
      "module/mem" = {
        type = "internal/memory";
        interval = 1;
        warn-percentage = 5;
        label = "%{T3} %{T-}%percentage_used%%";
        format-warn-background = harmonized.red;
        label-font = 1;
      };
      "module/temp" = {
        type = "internal/temperature";
        interval = 1;
        thermal-zone = 4;
        warn-temperature = 70;
        format = "<label>";
        format-warn = "%{F${harmonized.red}} <label-warn> %{F-}";
        label = "%{T3}%{T-} %temperature%";
        label-warn = "%{T3}%{T-} %temperature%";

      };
      "module/audio" = {
        type = "custom/script";
        tail = true;
        exec = mkScriptFromFile {
          deps = [ pkgs.pulseaudio pkgs.wireplumber pkgs.gawk ];
          scriptFile = ./polybar/volume-status.sh;
          args = [
            "alsa_output.pci-0000_00_1f.3.analog-stereo"
            "${colors.secondary}"
            "${harmonized.red}"
            ];
        };
        interval = "once";
        label = "%output%";
        label-font = 1;
      };
      "module/wlan" = {
        type = "custom/script";
        exec = mkScriptFromFile {
          deps = [ pkgs.iw pkgs.gawk ];
          scriptFile = ./polybar/wlan-status.sh;
          args = [
            "${harmonized.green}"
            "${harmonized.yellow}"
            "${harmonized.orange}"
            "${harmonized.red}"
          ];
        };
        interval = 10;
        format = "<label>";
        label = "%output%";
        label-font = 1;
      };
      "module/systemd" = {
        type = "custom/script";
        exec = mkScriptFromFile {
          deps = [ pkgs.systemdMinimal ];
          scriptFile = ./polybar/systemd-status.sh;
          args = [
            "${harmonized.green}"
            "${harmonized.red}"
          ];
        };
        interval = 60;
        format = "<label>";
        label = "%output%";
        label-font = 1;
      };
      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        format = "<label-layout> <label-indicator>";
        format-padding = "5px";
        label-font = 1;
        label-layout-padding = "5px";
        label-layout-background = "${colors.surface_bright}";
        label-layout-foreground = "${colors.primary}";
        label-indicator-background = "${colors.tertiary_container}";
        label-indicator-foreground = "${colors.primary}";
        label-indicator-padding = "5px";
      };
      "module/email" = {
        type = "custom/script";
        exec = mkScriptFromFile {
          deps = [pkgs.findutils pkgs.procps];
          scriptFile = ./polybar/email-status.sh;
          args = [ "${harmonized.green}" ];
        };
        interval = 60;
        format = "<label>";
        label = "%output%";
        label-font = 1;
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "AC0";
        full-at = 100;
        low-at = 10;
        interval = 10;

        format-discharging = "%{F${harmonized.red}}<ramp-capacity> <label-discharging>%{F-}";
        ramp-capacity-0 = "%{T3} %{T-}";
        ramp-capacity-1 = "%{T3} %{T-}";
        ramp-capacity-2 = "%{T3} %{T-}";
        ramp-capacity-3 = "%{T3} %{T-}";
        ramp-capacity-4 = "%{T3} %{T-}";
        label-discharging = "%percentage%% %time%";

        format-charging = "%{F${harmonized.green}}<animation-charging> <label-charging>%{F-}";
        animation-charging-0 = "%{T3} %{T-}";
        animation-charging-1 = "%{T3} %{T-}";
        animation-charging-2 = "%{T3} %{T-}";
        animation-charging-3 = "%{T3} %{T-}";
        animation-charging-4 = "%{T3} %{T-}";
        animation-charging-framerate = 500;
        label-charging = "%percentage%% %time%";
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
        # label-focused-underline = colors.secondary;
        label-focused-foreground = colors.primary;
        label-focused-background = colors.primary_container;

        label-visible = "%icon%";
        label-visible-padding = 2;

        label-urgent = "%index%";
        label-urgent-padding = 2;
      };
    };
  };
}
