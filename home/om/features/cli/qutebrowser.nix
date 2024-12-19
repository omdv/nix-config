{
  config,
  pkgs,
  lib,
  ...
}: let
  # inherit (config.colorscheme) colors;
  colors = {
    "background"= "#121318";
    "error"= "#ffb4ab";
    "error_container"= "#93000a";
    "inverse_on_surface"= "#303036";
    "inverse_primary"= "#4f5b92";
    "inverse_surface"= "#e3e1e9";
    "on_background"= "#e3e1e9";
    "on_error"= "#690005";
    "on_error_container"= "#ffdad6";
    "on_primary"= "#202c61";
    "on_primary_container"= "#dde1ff";
    "on_primary_fixed"= "#07164b";
    "on_primary_fixed_variant"= "#374379";
    "on_secondary"= "#2c2f42";
    "on_secondary_container"= "#dfe1f9";
    "on_secondary_fixed"= "#171b2c";
    "on_secondary_fixed_variant"= "#424659";
    "on_surface"= "#e3e1e9";
    "on_surface_variant"= "#c6c5d0";
    "on_tertiary"= "#44273e";
    "on_tertiary_container"= "#ffd7f3";
    "on_tertiary_fixed"= "#2c1229";
    "on_tertiary_fixed_variant"= "#5c3d56";
    "outline"= "#90909a";
    "outline_variant"= "#45464f";
    "primary"= "#b8c3ff";
    "primary_container"= "#374379";
    "primary_fixed"= "#dde1ff";
    "primary_fixed_dim"= "#b8c3ff";
    "scrim"= "#000000";
    "secondary"= "#c3c5dd";
    "secondary_container"= "#c3c5dd";
    "secondary_fixed"= "#dfe1f9";
    "secondary_fixed_dim"= "#c3c5dd";
    "shadow"= "#000000";
    "surface"= "#121318";
    "surface_bright"= "#38393f";
    "surface_container"= "#1f1f25";
    "surface_container_high"= "#292a2f";
    "surface_container_highest"= "#34343a";
    "surface_container_low"= "#1b1b21";
    "surface_container_lowest"= "#0d0e13";
    "surface_dim"= "#121318";
    "surface_variant"= "#45464f";
    "tertiary"= "#e4bad9";
    "tertiary_container"= "#5c3d56";
    "tertiary_fixed"= "#ffd7f3";
    "tertiary_fixed_dim"= "#e4bad9";
  };
  harmonized = {
    red = "#ff0000";
    green = "#00ff00";
    blue = "#0000ff";
    yellow = "#ffff00";
    orange = "#ffa500";
    purple = "#800080";
    pink = "#ffc0cb";
    brown = "#a52a2a";
    gray = "#808080";
    magenta = "#ff00ff";
    cyan = "#00ffff";
  } //colors;
in {
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["org.qutebrowser.qutebrowser.desktop"];
    "text/xml" = ["org.qutebrowser.qutebrowser.desktop"];
    "text/qute" = ["org.qutebrowser.qutebrowser.desktop"];
    "x-scheme-handler/qute" = ["org.qutebrowser.qutebrowser.desktop"];
  };

  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    settings = {
      downloads.open_dispatcher = "${lib.getExe pkgs.handlr-regex} open {}";
      editor.command = ["${lib.getExe pkgs.handlr-regex}" "open" "{file}"];
      tabs = {
        show = "multiple";
        position = "left";
        indicator.width = 0;
      };
      fonts = {
        default_family = config.fontProfiles.regular.family;
        default_size = "12pt";
      };
      colors = {
        webpage.preferred_color_scheme = "auto";
        completion = {
          fg = colors.on_surface;
          match.fg = colors.primary;
          even.bg = colors.surface_dim;
          odd.bg = colors.surface_bright;
          scrollbar = {
            bg = colors.surface;
            fg = colors.on_surface;
          };
          category = {
            bg = colors.secondary;
            fg = colors.on_secondary;
            border = {
              bottom = colors.surface;
              top = colors.surface;
            };
          };
          item.selected = {
            bg = colors.primary;
            fg = colors.on_primary;
            match.fg = colors.tertiary;
            border = {
              bottom = colors.outline;
              top = colors.outline;
            };
          };
        };
        contextmenu = {
          disabled = {
            bg = colors.surface_dim;
            fg = colors.on_surface_variant;
          };
          menu = {
            bg = colors.surface;
            fg = colors.on_surface;
          };
          selected = {
            bg = colors.secondary;
            fg = colors.on_secondary;
          };
        };
        downloads = {
          bar.bg = colors.surface_dim;
          error = {
            fg = colors.on_error;
            bg = colors.error;
          };
          start = {
            bg = colors.primary;
            fg = colors.on_primary;
          };
          stop = {
            bg = colors.secondary;
            fg = colors.on_secondary;
          };
        };
        hints = {
          bg = colors.secondary;
          fg = colors.on_secondary;
          match.fg = colors.on_surface;
        };
        keyhint = {
          bg = colors.surface;
          fg = colors.on_surface;
          suffix.fg = colors.on_surface;
        };
        messages = {
          error = {
            bg = colors.error;
            border = colors.outline;
            fg = colors.on_error;
          };
          info = {
            bg = colors.secondary;
            border = colors.outline;
            fg = colors.on_secondary;
          };
          warning = {
            bg = colors.primary;
            border = colors.outline;
            fg = colors.on_primary;
          };
        };
        prompts = {
          bg = colors.surface;
          fg = colors.on_surface;
          border = colors.surface;
          selected.bg = colors.inverse_primary;
        };
        statusbar = {
          caret = {
            bg = colors.surface;
            fg = colors.on_surface;
            selection = {
              bg = colors.surface;
              fg = colors.on_surface_variant;
            };
          };
          command = {
            bg = colors.surface_bright;
            fg = colors.on_surface;
            private = {
              bg = colors.surface_bright;
              fg = colors.on_surface;
            };
          };
          insert = {
            bg = colors.surface;
            fg = colors.primary;
          };
          normal = {
            bg = colors.surface;
            fg = colors.on_surface;
          };
          passthrough = {
            bg = colors.secondary;
            fg = colors.on_secondary;
          };
          private = {
            bg = colors.tertiary;
            fg = colors.on_tertiary;
          };
          progress.bg = colors.tertiary;
          url = {
            error.fg = colors.error;
            fg = colors.on_surface;
            success = {
              http.fg = colors.secondary;
              https.fg = colors.secondary;
            };
            warn.fg = colors.tertiary;
          };
        };
        tabs = {
          bar.bg = colors.surface;
          even = {
            bg = colors.surface_bright;
            fg = colors.on_surface;
          };
          odd = {
            bg = colors.surface_dim;
            fg = colors.on_surface;
          };
          selected = {
            even = {
              bg = colors.primary;
              fg = colors.on_primary;
            };
            odd = {
              bg = colors.primary;
              fg = colors.on_primary;
            };
          };
          pinned = {
            even = {
              bg = colors.surface_bright;
              fg = colors.tertiary;
            };
            odd = {
              bg = colors.surface_dim;
              fg = colors.tertiary;
            };
            selected = {
              even = {
                bg = colors.tertiary;
                fg = colors.on_tertiary;
              };
              odd = {
                bg = colors.tertiary;
                fg = colors.on_tertiary;
              };
            };
          };
        };
      };
    };
    extraConfig = ''
      c.tabs.padding = {"bottom": 10, "left": 10, "right": 10, "top": 10}
    '';
  };

  xdg.configFile."qutebrowser/config.py".onChange = lib.mkForce ''
    ${pkgs.procps}/bin/pkill -u $USER -HUP qutebrowser || true
  '';
}
