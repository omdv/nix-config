{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  getHostname = x: lib.last (lib.splitString "@" x);
  remoteColorschemes = lib.mapAttrs' (n: v: {
    name = getHostname n;
    value = v.config.colorscheme.rawColorscheme.colors.${config.colorscheme.mode};
  }) outputs.homeConfigurations;
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";
in {
  imports = [
    ../common/wayland-wm

    ./basic-binds.nix
    # ./hyprbars.nix
  ];

  xdg.portal = let
    hyprland = config.wayland.windowManager.hyprland.package;
    xdph = pkgs.xdg-desktop-portal-hyprland.override {inherit hyprland;};
  in {
    extraPortals = [xdph];
    configPackages = [hyprland];
  };

  home.packages = with pkgs; [
    grimblast
    hyprpicker
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland.override {wrapRuntimeDeps = false;};
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      general = {
        gaps_in = 15;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = rgba config.colorscheme.colors.primary "aa";
        "col.inactive_border" = rgba config.colorscheme.colors.surface_bright "aa";
      };

      bind = let
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
          # Program bindings
          "ALT,Return,exec,${defaultApp "x-scheme-handler/terminal"}"
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
        ++ (
          let
            playerctl = lib.getExe' config.services.playerctld.package "playerctl";
            playerctld = lib.getExe' config.services.playerctld.package "playerctld";
          in
            lib.optionals config.services.playerctld.enable [
              # Media control
              ",XF86AudioNext,exec,${playerctl} next"
              ",XF86AudioPrev,exec,${playerctl} previous"
              ",XF86AudioPlay,exec,${playerctl} play-pause"
              ",XF86AudioStop,exec,${playerctl} stop"
              "ALT,XF86AudioNext,exec,${playerctld} shift"
              "ALT,XF86AudioPrev,exec,${playerctld} unshift"
              "ALT,XF86AudioPlay,exec,systemctl --user restart playerctld"
            ]
        )
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
  };
}
