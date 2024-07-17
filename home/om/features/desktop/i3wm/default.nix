{ pkgs, lib, ... }: {
  imports = [
    ./keybindings.nix
    ./statusbar.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
    };
  };
}
