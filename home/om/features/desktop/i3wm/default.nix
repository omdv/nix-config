# TODO parameterize xft.dpi via config.monitor
{ pkgs, config, ... }: {
  imports = [
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

      fonts = {
        names = [ config.fontProfiles.monospace.family ];
        style = "Mono";
        size = 8.0;
      };

      gaps = {
        inner = 2;
        top = 10;
      };
    };
  };
}
