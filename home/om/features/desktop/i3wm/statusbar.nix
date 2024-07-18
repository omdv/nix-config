# TODO try notmuch block
# TODO try rofi notification
# TODO number of failed services
{
  pkgs,
  lib,
  config,
  ...
}: let
  commonDeps = with pkgs; [coreutils gnugrep systemd];
  # Function to simplify making waybar outputs
  mkScript = {
    name ? "script",
    deps ? [],
    script ? "",
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = script;
      runtimeInputs = commonDeps ++ deps;
    });
  # Specialized for JSON outputs
  mkScriptJson = {
    name ? "script",
    deps ? [],
    pre ? "",
    text ? "",
    alt ? "",
    state ? "",
  }:
    mkScript {
      deps = [pkgs.jq] ++ deps;
      script = ''
        ${pre}
        jq -cn \
          --arg text "${text}" \
          --arg alt "${alt}" \
          --arg state "${state}" \
          '{text:$text,alt:$alt,state:$state}'
      '';
    };
in {
  xsession.windowManager.i3 = {
    config = {
      bars = [
        {
          fonts = {
            names = [ config.fontProfiles.regular.family ];
            size = 10.;
          };
          position = "top";
          statusCommand = "${lib.getExe config.programs.i3status-rust.package} ~/.config/i3status-rust/config-top.toml";
        }
      ];
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
          {
            block = "memory";
            format = " $icon $mem_used_percents ";
            interval = 5;
          }
          {
            block = "cpu";
            interval = 5;
          }
          {
            block = "temperature";
            format = " $icon $average";
            format_alt = " $icon $max max";
            interval = 5;
          }
          {
            block = "sound";
            click = [{
              button = "left";
              cmd = "${lib.getExe pkgs.pavucontrol} --tab=3";
            }];
          }
          {
            block = "battery";
            format = " $icon $percentage ";
            interval = 30;
          }
          {
            block = "time";
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            click = [{
              button = "left";
              cmd = "cal";
            }];
            interval = 60;
          }
          {
            # number of failed services
            block = "custom";
            interval = 10;
            json = true;
            command = mkScriptJson {
              pre = ''
                count=$(systemctl --user list-units | grep -c "failed")
                if [ "$count" == "0" ]; then
                  status="$count"
                  state="Good"
                else
                  status="$count"
                  state="Bad"
                fi
              '';
              text = "$status";
              state = "$state";
            };
          }
          # {
          #   # whether gpg is unlocked
          #   block = "custom";
          #   interval = 10;
          #   json = true;
          #   command = mkScriptJson {
          #     pre = ''
          #       count=$(gpg-connect-agent 'keyinfo --list' /bye | awk '{print $7}' | grep '1')
          #       if [ "$count" == "1" ]; then
          #         status="{\"state\":\"Bad\", \"text\": \"unlocked\"}"
          #       else
          #         status="{\"state\":\"Good\", \"text\": \"locked\"}"
          #       fi
          #     '';
          #     # 
          #     text = "$status";
          #   };
          # }
          # {
          #   block = "custom";
          #   interval = 10;
          #   json = true;
          #   command = mkScriptJson {
          #     deps = [pkgs.findutils pkgs.procps];
          #     pre = ''
          #       count=$(find ~/Mail/*/Inbox/new -type f | wc -l)
          #       if pgrep mbsync &>/dev/null; then
          #         status="syncing"
          #       else
          #         if [ "$count" == "0" ]; then
          #           status="󰇯"
          #         else
          #           status="󰇮 $count"
          #         fi
          #       fi
          #     '';
          #     text = "$status";
          #     alt = "$status";
          #   };
          # }
          {
            block = "custom";
            command = "echo ⏻ ";
            interval = "once";
            click = [{
              button = "left";
              cmd = "systemctl `echo -e 'suspend\npoweroff\nreboot' | rofi -dmenu`";
            }];
          }
        ];
        theme = "dracula";
      };
    };
  };
}
