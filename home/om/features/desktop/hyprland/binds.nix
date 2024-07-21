{
  pkgs,
  lib,
  config,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
    ];

    bind = let
      workspaces = [
        "0"
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "F1"
        "F2"
        "F3"
        "F4"
        "F5"
        "F6"
        "F7"
        "F8"
        "F9"
        "F10"
        "F11"
        "F12"
      ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l";
        right = "r";
        up = "u";
        down = "d";
        h = left;
        l = right;
        k = up;
        j = down;
      };

      grimblast = lib.getExe pkgs.grimblast;
      tesseract = lib.getExe pkgs.tesseract;
      pactl = lib.getExe' pkgs.pulseaudio "pactl";
      notify-send = lib.getExe' pkgs.libnotify "notify-send";
      defaultApp = type: "${lib.getExe pkgs.handlr-regex} launch ${type}";
      remote = lib.getExe (pkgs.writeShellScriptBin "remote" ''
        socket="$(basename "$(find ~/.ssh -name 'master-*' | head -1 | cut -d ':' -f1)")"
        host="''${socket#master-}"
        ssh "$host" "$@"
      '');
    in
      [
        # Basic bindings
        "SUPERSHIFT,q,killactive"
        "SUPERSHIFT,e,exit"

        "SUPER,s,togglesplit"
        "SUPER,f,fullscreen,1"
        "SUPERSHIFT,f,fullscreen,0"
        "SUPERSHIFT,space,togglefloating"

        "SUPER,minus,splitratio,-0.25"
        "SUPERSHIFT,minus,splitratio,-0.3333333"

        "SUPER,equal,splitratio,0.25"
        "SUPERSHIFT,equal,splitratio,0.3333333"

        "SUPER,g,togglegroup"
        "SUPER,t,lockactivegroup,toggle"
        "SUPER,tab,changegroupactive,f"
        "SUPERSHIFT,tab,changegroupactive,b"

        "SUPER,apostrophe,workspace,previous"
        "SUPERSHIFT,apostrophe,workspace,next"

        "SUPER,u,togglespecialworkspace"
        "SUPERSHIFT,u,movetoworkspacesilent,special"
        "SUPER,i,pseudo"

        # Program bindings
        "SUPER,Return,exec,${defaultApp "x-scheme-handler/terminal"}"
        "SUPER,e,exec,${defaultApp "text/plain"}"
        "SUPER,b,exec,${defaultApp "x-scheme-handler/https"}"
        "SUPERALT,Return,exec,${remote} ${defaultApp "x-scheme-handler/terminal"}"
        "SUPERALT,e,exec,${remote} ${defaultApp "text/plain"}"
        "SUPERALT,b,exec,${remote} ${defaultApp "x-scheme-handler/https"}"

        # Brightness control (only works if the system has lightd)
        ",XF86MonBrightnessUp,exec,light -A 10"
        ",XF86MonBrightnessDown,exec,light -U 10"

        # Volume
        ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"

        # Screenshotting
        ",Print,exec,${grimblast} --notify --freeze copy output"
        "SUPER,Print,exec,${grimblast} --notify --freeze copy area"

        # To OCR
        "ALT,Print,exec,${grimblast} --freeze save area - | ${tesseract} - - | wl-copy && ${notify-send} -t 3000 'OCR result copied to buffer'"
      ]
      ++
      # Change workspace
      (map (n: "SUPER,${n},workspace,name:${n}") workspaces)
      ++
      # Move window to workspace
      (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,name:${n}") workspaces)
      ++
      # Move focus
      (lib.mapAttrsToList (key: direction: "SUPER,${key},movefocus,${direction}") directions)
      ++
      # Swap windows
      (lib.mapAttrsToList (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}") directions)
      ++
      # Move windows
      (lib.mapAttrsToList (
          key: direction: "SUPERCONTROL,${key},movewindoworgroup,${direction}"
        )
        directions)
      ++
      # Move monitor focus
      (lib.mapAttrsToList (key: direction: "SUPERALT,${key},focusmonitor,${direction}") directions)
      ++
      # Move workspace to other monitor
      (lib.mapAttrsToList (
          key: direction: "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
        )
        directions)
      ++
      # Screen lock
      (
        let
          swaylock = lib.getExe config.programs.swaylock.package;
        in
          lib.optionals config.programs.swaylock.enable [
            ",XF86Launch5,exec,${swaylock} -S --grace 2"
            ",XF86Launch4,exec,${swaylock} -S --grace 2"
            "SUPER,backspace,exec,${swaylock} -S --grace 2"
          ]
      )
      ++
      # Notification manager
      (
        let
          makoctl = lib.getExe' config.services.mako.package "makoctl";
        in
          lib.optionals config.services.mako.enable [
            "SUPER,w,exec,${makoctl} dismiss"
            "SUPERSHIFT,w,exec,${makoctl} restore"
          ]
      )
      ++
      # Launcher
      (
        let
          wofi = lib.getExe config.programs.wofi.package;
        in
          lib.optionals config.programs.wofi.enable [
            "SUPER,x,exec,${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
            "SUPER,s,exec,specialisation $(specialisation | ${wofi} -S dmenu)"
            "SUPER,d,exec,${wofi} -S run"

            "SUPERALT,x,exec,${remote} ${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
            "SUPERALT,d,exec,${remote} ${wofi} -S run"
          ]
          ++ (
            let
              pass-wofi = lib.getExe (pkgs.pass-wofi.override {pass = config.programs.password-store.package;});
            in
              lib.optionals config.programs.password-store.enable [
                ",Scroll_Lock,exec,${pass-wofi}" # fn+k
                ",XF86Calculator,exec,${pass-wofi}" # fn+f12
                "SUPER,semicolon,exec,${pass-wofi}"
                "SHIFT,Scroll_Lock,exec,${pass-wofi} fill" # fn+k
                "SHIFT,XF86Calculator,exec,${pass-wofi} fill" # fn+f12
                "SHIFTSUPER,semicolon,exec,${pass-wofi} fill"
              ]
          ) ++ (
            let
              cliphist = lib.getExe config.services.cliphist.package;
            in
            lib.optionals config.services.cliphist.enable [
              ''SUPER,c,exec,selected=$(${cliphist} list | ${wofi} -S dmenu) && echo "$selected" | ${cliphist} decode | wl-copy''
            ]
          )
      );
  };
}
