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
        "${mod}+h" = "split h";
        "${mod}+v" = "split v";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";

        # screenshot
        "${mod}+Print" = "exec ${pkgs.maim}/bin/maim -s ${config.home.homeDirectory}/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png";
        "${mod}+Shift+Print" = "exec ${pkgs.maim}/bin/maim -s ${config.home.homeDirectory}/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png";

        # wifi control
        "${mod}+n" = "exec ${mkScriptFromFile {
          deps = [pkgs.networkmanager pkgs.iw];
          scriptFile = ./scripts/wifi-menu.sh;
          args = [ "${config.fontProfiles.monospace.family} 16" ];
        }}";

        # volume control
        "XF86AudioRaiseVolume" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/volume-control.sh;
          args = [ "up" "0.01"];
        }}";
        "XF86AudioLowerVolume" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/volume-control.sh;
          args = [ "down" "0.01" ];
        }}";
        "XF86AudioMute" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/volume-control.sh;
          args = [ "mute" ];
        }}";

        # brightness control
        "XF86MonBrightnessUp" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/brightness-control.sh;
          args = [ "up" "1"];
        }}";
        "XF86MonBrightnessDown" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/brightness-control.sh;
          args = [ "down" "1" ];
        }}";
        "${mod}+XF86MonBrightnessUp" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/brightness-control.sh;
          args = [ "up" "1"];
        }}";
        "${mod}+XF86MonBrightnessDown" = "exec ${mkScriptFromFile {
          deps = [];
          scriptFile = ./scripts/brightness-control.sh;
          args = [ "down" "1" ];
        }}";
      };
      modes = {
        resize = {
          Left   = "resize shrink width 10 px or 10 ppt";
          Down   = "resize grow height 10 px or 10 ppt";
          Up     = "resize shrink height 10 px or 10 ppt";
          Right  = "resize grow width 10 px or 10 ppt";
          Return = "mode default";
          Escape = "mode default";
        };
      };
    };
  };
}
