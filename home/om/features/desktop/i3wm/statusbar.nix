{ lib, config, ... }: {
  xsession.windowManager.i3 = {
    config = {
      bars = [
        {
          fonts = {
            names = [ config.fontProfiles.monospace.family ];
            style = "Mono";
            size = 14.0;
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
          }
          {
            block = "time";
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            interval = 60;
          }
        ];
      };
    };
  };
}
