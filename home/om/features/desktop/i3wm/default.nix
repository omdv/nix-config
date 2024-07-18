# TODO parameterize xft.dpi via config.monitor
{ pkgs, config, ... }: {
  imports = [
    ./rofi.nix
    ./keybindings.nix
    ./statusbar.nix
  ];

  # scaling, etc
  xresources.properties = {
    "Xft.antialias" = true;
    "Xft.dpi" = config.i3scaling.dpi;
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {

      defaultWorkspace = "1";

      fonts = {
        names = [
          config.fontProfiles.monospace.family
          config.fontProfiles.icons.family
          ];
        size = 12.0;
      };

      window = {
        commands = [{
          command = "border pixel 1";
          criteria.class = "*";
        }];
        titlebar = false;
      };

      gaps = {
        inner = 2;
        top = 2;
      };
    };
  };
}
