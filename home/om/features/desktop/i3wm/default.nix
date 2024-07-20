{ pkgs, config, ... }: {
  imports = [
    ./rofi.nix
    ./keybindings.nix
    ./polybar.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      bars = [];
      defaultWorkspace = "1";
      fonts = {
        names = [
          config.fontProfiles.monospace.family
          config.fontProfiles.icons.family
          ];
        size = 12.0;
      };
      window = {
        border = 0;
        titlebar = false;
        hideEdgeBorders = "smart";
      };
      gaps = {
        inner = 2;
        top = 2;
      };
      startup = [
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-scale ${config.wallpaper}";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
