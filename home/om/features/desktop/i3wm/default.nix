{
  pkgs,
  config,
  ...
}: let
  colors = config.colorscheme.palette;
in {
  imports = [
    ../common/rofi.nix

    ./keybindings.nix
    ./picom.nix
    ./polybar.nix
    ./dunst.nix
  ];

  home.packages = with pkgs; [xss-lock i3lock];

  xsession.initExtra = ''
    xset s 600             # blank screen after 10 min idle
    xset dpms 600 600 900  # display off at 10/10/15 min
  '';

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    config = {
      assigns = {
        "2" = [
          {class = "firefox";}
          {class = "Brave-browser";}
        ];
        "3" = [
          {class = "Code";}
          {class = "Cursor";}
          {class = "dev.zed.Zed";}
        ];
        "5" = [
          {class = "TelegramDesktop";}
          {class = "discord";}
        ];
        "6" = [{class = "net-sourceforge-kolmafia-KoLmafia";}];
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
        {
          command = "${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- ${pkgs.i3lock}/bin/i3lock --nofork -c ${colors.base00}";
          notification = false;
        }
        {
          command = "brave";
          notification = false;
        }
        {
          command = "i3-msg workspace 1";
          notification = false;
        }
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
