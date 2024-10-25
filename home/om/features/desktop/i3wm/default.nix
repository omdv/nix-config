#TODO: lxappearance for styling?

{ pkgs, config, ... }: let
  inherit (config.colorscheme) colors;

  # matugen color -t scheme-tonal-spot hex "#2B3975" --show-colors
  # colors = {
  #   "background"= "#121318";
  #   "error"= "#ffb4ab";
  #   "error_container"= "#93000a";
  #   "inverse_on_surface"= "#303036";
  #   "inverse_primary"= "#4f5b92";
  #   "inverse_surface"= "#e3e1e9";
  #   "on_background"= "#e3e1e9";
  #   "on_error"= "#690005";
  #   "on_error_container"= "#ffdad6";
  #   "on_primary"= "#202c61";
  #   "on_primary_container"= "#dde1ff";
  #   "on_primary_fixed"= "#07164b";
  #   "on_primary_fixed_variant"= "#374379";
  #   "on_secondary"= "#2c2f42";
  #   "on_secondary_container"= "#dfe1f9";
  #   "on_secondary_fixed"= "#171b2c";
  #   "on_secondary_fixed_variant"= "#424659";
  #   "on_surface"= "#e3e1e9";
  #   "on_surface_variant"= "#c6c5d0";
  #   "on_tertiary"= "#44273e";
  #   "on_tertiary_container"= "#ffd7f3";
  #   "on_tertiary_fixed"= "#2c1229";
  #   "on_tertiary_fixed_variant"= "#5c3d56";
  #   "outline"= "#90909a";
  #   "outline_variant"= "#45464f";
  #   "primary"= "#b8c3ff";
  #   "primary_container"= "#374379";
  #   "primary_fixed"= "#dde1ff";
  #   "primary_fixed_dim"= "#b8c3ff";
  #   "scrim"= "#000000";
  #   "secondary"= "#c3c5dd";
  #   "secondary_container"= "#c3c5dd";
  #   "secondary_fixed"= "#dfe1f9";
  #   "secondary_fixed_dim"= "#c3c5dd";
  #   "shadow"= "#000000";
  #   "surface"= "#121318";
  #   "surface_bright"= "#38393f";
  #   "surface_container"= "#1f1f25";
  #   "surface_container_high"= "#292a2f";
  #   "surface_container_highest"= "#34343a";
  #   "surface_container_low"= "#1b1b21";
  #   "surface_container_lowest"= "#0d0e13";
  #   "surface_dim"= "#121318";
  #   "surface_variant"= "#45464f";
  #   "tertiary"= "#e4bad9";
  #   "tertiary_container"= "#5c3d56";
  #   "tertiary_fixed"= "#ffd7f3";
  #   "tertiary_fixed_dim"= "#e4bad9"
  # };
in {
  imports = [
    ./rofi.nix
    ./keybindings.nix
    ./picom.nix
    ./polybar.nix
    ./dunst.nix
  ];

  xsession.initExtra = ''
    xset s off          # Disable screen saver
    xset -dpms          # Disable DPMS (Display Power Management Signaling)
  '';

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      assigns = {
        "2" = [{ class = "firefox"; }];
        "3" = [{ class = "Code"; }];
      };
      bars = [];
      defaultWorkspace = "1";
      fonts = {
        names = [
          config.fontProfiles.monospace.family
          config.fontProfiles.icons.family
          ];
        size = 12.0;
      };
      window = {
        border = 0;
        titlebar = false;
        hideEdgeBorders = "smart";
      };
      gaps = {
        smartGaps = false;
        inner = 5;
        top = 50;
        bottom = 5;
      };
      startup = [
        { command = "firefox"; notification = false; }
        { command = "i3-msg workspace 1"; notification = false; }
        {
          command = "setxkbmap -layout us,ua -variant ,, -option grp:win_space_toggle";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "gnome-keyring-daemon --start --components=pkcs11,secrets";
          always = true;
          notification = false;
        }
        {
          command = "xsetroot -solid '${colors.background}'";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
