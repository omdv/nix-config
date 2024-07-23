{ pkgs, lib, config, ... }: {
  xsession.windowManager.i3 = {
    config = {
      modifier = "Mod4";
      keybindings = let
        mod = config.xsession.windowManager.i3.config.modifier;
      in lib.mkOptionDefault {
        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
        # normal volume control
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
        # granular volume control
        "${mod}+XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+";
        "${mod}+XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-";
        # mute
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
    };
  };
}
