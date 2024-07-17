{ pkgs, config, ... }: {
  imports = [
    ./keybindings.nix
    ./statusbar.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {

      fonts = {
        names = [ config.fontProfiles.monospace.family ];
        style = "Mono";
        size = 14.0;
      };

      gaps = {
        inner = 2;
        top = 25;
      };
    };
  };
}
