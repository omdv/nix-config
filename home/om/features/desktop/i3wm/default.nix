{ pkgs, config, ... }: let
  colors = config.colorscheme.palette;
in {
  imports = [
    ./rofi.nix
    ./keybindings.nix
    ./picom.nix
    ./polybar.nix
    ./dunst.nix
  ];

  xsession.initExtra = ''
    xset s off          # Disable screen saver
    xset -dpms          # Disable DPMS (Display Power Management Signaling)
  '';

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      assigns = {
        "2" = [
          { class = "firefox"; }
          { class = "Brave-browser"; }
        ];
        "3" = [
          { class = "Code"; }
          { class = "Cursor"; }
          { class = "dev.zed.Zed"; }
        ];
        "5" = [
          { class = "TelegramDesktop"; }
          { class = "discord"; }
        ];
        "6" = [{ class = "net-sourceforge-kolmafia-KoLmafia"; }];
      };
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
        smartGaps = false;
        inner = 5;
        top = 50;
        bottom = 5;
      };
      startup = [
        { command = "brave"; notification = false; }
        { command = "i3-msg workspace 1"; notification = false; }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "xsetroot -solid '${colors.base00}'";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
