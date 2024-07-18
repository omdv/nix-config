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
    tooltip ? "",
    alt ? "",
    class ? "",
    percentage ? "",
  }:
    mkScript {
      deps = [pkgs.jq] ++ deps;
      script = ''
        ${pre}
        jq -cn \
          --arg text "${text}" \
          --arg tooltip "${tooltip}" \
          --arg alt "${alt}" \
          --arg class "${class}" \
          --arg percentage "${percentage}" \
          '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
      '';
    };
in {
  xsession.windowManager.i3 = {
    config = {
      bars = [
        {
          fonts = {
            names = [ config.fontProfiles.regular.family ];
            # style = "Mono";
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
            format_alt = " $icon $swap_used_percents ";
          }
          {
            block = "cpu";
            interval = 1;
          }
          {
            block = "custom";
            interval = 10;
            json = true;
            command = mkScriptJson {
              deps = [pkgs.findutils pkgs.procps];
              pre = ''
                count=$(find ~/Mail/*/Inbox/new -type f | wc -l)
                if pgrep mbsync &>/dev/null; then
                  status="syncing"
                else
                  if [ "$count" == "0" ]; then
                    status="read"
                  else
                    status="unread"
                  fi
                fi
              '';
              text = "󰇮  $count";
              alt = "$status";
            };
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
            block = "custom";
            command = "echo \\U23fb";
            interval = "once";
            click = [{
              button = "left";
              cmd = "systemctl `echo -e 'suspend\npoweroff\nreboot' | dmenu`";
            }];
          }
        ];
        # icons = "material-nf";
        theme = "dracula";
      };
    };
  };
}
