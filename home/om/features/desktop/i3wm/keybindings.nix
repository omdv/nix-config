{ pkgs, lib, config, ... }: let
  mapStrings = f: xs: lib.map (x: f x) xs;
  commonDeps = with pkgs; [coreutils gnugrep];
  mkScriptFromFile = {
    name ? "script",
    deps ? [],
    scriptFile ? "",
    args ? [],
  }:
    let
      quotedArgs = lib.concatStringsSep " " (mapStrings (arg: "\"${arg}\"") args);
    in
      lib.getExe (pkgs.writeShellApplication {
        inherit name;
        text = builtins.readFile scriptFile; # or just text=cmd
        runtimeInputs = commonDeps ++ deps;
      })  + " " + quotedArgs;
in {
  xsession.windowManager.i3 = {
    config = {
      modifier = "Mod4";
      keybindings = let
        mod = config.xsession.windowManager.i3.config.modifier;
      in lib.mkOptionDefault {

        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";

        # volume control
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ && dunstify 'Volume +5%'";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05- && dunstify 'Volume -5%'";
        "${mod}+XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+ && dunstify 'Volume +1%'";
        "${mod}+XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01- && dunstify 'Volume -1%'";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && dunstify 'Volume toggle'";

        # backlight control
        "XF86MonBrightnessUp" = "exec ${mkScriptFromFile {
          deps = [ pkgs.acpilight ];
          scriptFile = ./scripts/brightness-control.sh;
          args = [ "up" ];
        }}";
        "XF86MonBrightnessDown" = "exec ${mkScriptFromFile {
          deps = [ pkgs.acpilight ];
          scriptFile = ./scripts/brightness-control.sh;
          args = [ "down" ];
        }}";
      };
    };
  };
}
