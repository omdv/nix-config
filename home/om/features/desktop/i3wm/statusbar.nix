{ pkgs, lib, config, ... }: {
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
