{ pkgs, lib, config, ... }: {
  xsession.windowManager.i3 = {
    config = {
      modifier = "Mod4";
      keybindings = let
        mod = config.xsession.windowManager.i3.config.modifier;
      in lib.mkOptionDefault {
        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/dmenu_run";
      };
    };
  };
}
