{ config, lib, pkgs, ... }:
let
  colors = config.colorscheme.palette;
  # Explicit icon path: recursive GTK lookup fails for audio icons because
  # Papirus only ships audio-volume-* up to 24x24 (actions context), below
  # the GTK size-match threshold. Pointing dunst directly at the nix store
  # path is reliable regardless of XDG_DATA_DIRS at daemon startup.
  iconPath = lib.concatStringsSep ":" [
    "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/actions"
    "${pkgs.papirus-icon-theme}/share/icons/Papirus/32x32/apps"
    "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48/apps"
    "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps"
  ];
in {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = "(0, 300)"; # dynamic; was a fixed 100px cap
        origin = "top-right";
        offset = "(30, 100)"; # clears polybar at top

        # Rounded window corners — X SHAPE extension, no compositor needed
        corner_radius = 10;
        corners = "all";

        # Per-notification frame + gap; replaces single separator line
        gap_size = 5;
        separator_height = 0;
        frame_width = 2;
        frame_color = "#${colors.base0D}";

        # Spacing
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 8;

        # picom is disabled; dunst transparency requires a compositor — keep opaque
        transparency = 0;

        # Text
        font = "${config.fontProfiles.monospace.family} 12";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        word_wrap = true;
        ellipsize = "middle";
        line_height = 0;

        # Native progress bar — rendered when scripts pass -h int:value:N
        progress_bar = true;
        progress_bar_height = 8;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 150;
        progress_bar_max_width = 280;
        progress_bar_corner_radius = 4;
        progress_bar_corners = "all";

        # Icons — explicit nix store path sidesteps GTK theme lookup at runtime
        icon_position = "left";
        enable_recursive_icon_lookup = false;
        icon_path = iconPath;
        min_icon_size = 32;
        max_icon_size = 64;
        icon_corner_radius = 4;
        icon_corners = "all";

        # Stacking
        stack_duplicates = true;
        hide_duplicate_count = false;
        notification_limit = 5;

        # History
        history_length = 30;
        sticky_history = true;

        # Mouse
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";

        # Misc
        show_indicators = true;
        enable_posix_regex = true;
        sort = "urgency_descending";
        browser = "${pkgs.xdg-utils}/bin/xdg-open";
      };

      urgency_low = {
        background = "#${colors.base00}";
        foreground = "#${colors.base04}";
        frame_color = "#${colors.base03}";
        timeout = 3;
        default_icon = "dialog-information";
      };

      urgency_normal = {
        background = "#${colors.base01}";
        foreground = "#${colors.base06}";
        frame_color = "#${colors.base0D}";
        timeout = 5;
        default_icon = "dialog-information";
      };

      urgency_critical = {
        background = "#${colors.base01}";
        foreground = "#${colors.base08}";
        frame_color = "#${colors.base08}";
        timeout = 0; # sticky — requires manual dismissal
        default_icon = "dialog-warning";
      };

      # Critical breaks through fullscreen unconditionally
      fullscreen_show_critical = {
        msg_urgency = "critical";
        fullscreen = "show";
      };

      # Normal/low defers when fullscreen (gaming, video)
      fullscreen_delay_normal = {
        msg_urgency = "normal";
        fullscreen = "delay";
      };

      # OSD-style volume/brightness notifications from scripts:
      # matched by x-dunst-stack-tag=osd, compact format, short timeout,
      # subtle frame so they read as transient status rather than alerts.
      osd = {
        stack_tag = "osd";
        format = "<b>%s</b>"; # summary only; progress bar renders below
        timeout = 2;
        frame_color = "#${colors.base03}";
      };
    };
  };
}
