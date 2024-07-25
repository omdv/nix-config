# TODO try notmuch block
# TODO try rofi notification
# TODO number of failed services

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
        text = builtins.readFile scriptFile;
        runtimeInputs = commonDeps ++ deps;
      })  + " " + quotedArgs;

  mkScript = {
    name ? "script",
    deps ? [],
    cmd ? "",
    args ? [],
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = cmd;
      runtimeInputs = commonDeps ++ deps;
    })  + " " + lib.concatStringsSep " " args;
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
        height = "3%";
        override-redirect = true;
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
        font-2 = "${config.fontProfiles.icons.family}:size=12;3";

      };
      "bar/top" = {
        "inherit" = "bar/root";
        width = "100%";
        offset-y = 0;
        modules-left = "i3";
        modules-center = "date";
        modules-right = "cpu mem temp audio wlan systemd email battery";
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
        warn-percentage = 5;
        label = "CPU %percentage%%";
        format-warn-background = colors.error;
        label-font = 1;
      };
      "module/mem" = {
        type = "internal/memory";
        interval = 1;
        warn-percentage = 5;
        label = "MEM %percentage_used%%";
        format-warn-background = colors.error;
        label-font = 1;
      };
      "module/temp" = {
        type = "internal/temperature";
        interval = 1;
        label = "TEMP %temperature%";
        thermal-zone = 5;
        warn-temperature = 60;
        format = "%{F${harmonized.green}} <label> {F-}";
        format-warn = "%{F${harmonized.red}} <label> {F-}";
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT1";
        adapter = "AC0";
        full-at = 100;
        low-at = 10;
        label-font = 1;
        label = "BAT %percentage%%";
        interval = 60;
      };
      "module/audio" = {
        type = "custom/script";
        tail = true;
        exec = mkScriptFromFile {
          deps = [ pkgs.pulseaudio pkgs.wireplumber pkgs.gawk ];
          scriptFile = ./polybar/volume-status.sh;
          args = [
            "alsa_output.pci-0000_00_1f.3.analog-stereo"
            "${harmonized.green}"
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
        interval = 1;
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
          # cmd = ''
          # count=$(systemctl --user list-units -all | grep -c "failed" | tr -d \\n)
          # # if [ "$count" == "0" ]; then
          # #   status=" "
          # # else
          # #   status="  $count"
          # # fi
          # echo "$count"
          # '';
        };
        interval = 60;
        format = "<label>";
        label = "%output%";
        label-font = 1;
      };
      "module/email" = {
        type = "custom/script";
        exec = mkScript {
          deps = [pkgs.findutils pkgs.procps];
          cmd = ''
            count=$(find ~/Mail/*/Inbox/new -type f | wc -l)
            if pgrep mbsync &>/dev/null; then
              status="syncing"
            # else
            #   if [ "$count" == "0" ]; then
            #     status="󰇯"
            #   else
            #     status="󰇮 $count"
            #   fi
            fi
            status="$count"
            echo "MAIL $status"
          '';
        };
        interval = 60;
        format = "<label>";
        label = "%output%";
        label-font = 3;
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
