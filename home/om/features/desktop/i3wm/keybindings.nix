{ pkgs, lib, config, ... }: {
  xsession.windowManager.i3 = {
    config = {
      modifier = "Mod4";
      keybindings = let
        mod = config.xsession.windowManager.i3.config.modifier;
      in lib.mkOptionDefault {
        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
        # volume
# # gradular volume control
# bindsym $mod+XF86AudioRaiseVolume exec amixer -D pulse sset Master 1%+ && pkill -RTMIN+1 polybar
# bindsym $mod+XF86AudioLowerVolume exec amixer -D pulse sset Master 1%- && pkill -RTMIN+1 polybar

# # mute
# bindsym XF86AudioMute exec amixer sset Master toggle && killall -USR1 polybar
      };
    };
  };
}
