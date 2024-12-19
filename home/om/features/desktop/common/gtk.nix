{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) hashString toJSON;
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
  rendersvg = pkgs.runCommand "rendersvg" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';
  materiaTheme = name: colors:
    pkgs.stdenv.mkDerivation {
      name = "generated-gtk-theme";
      src = pkgs.fetchFromGitHub {
        owner = "nana-4";
        repo = "materia-theme";
        rev = "76cac96ca7fe45dc9e5b9822b0fbb5f4cad47984";
        sha256 = "sha256-0eCAfm/MWXv6BbCl2vbVbvgv8DiUH09TAUhoKq7Ow0k=";
      };
      buildInputs = with pkgs; [
        sassc
        bc
        which
        rendersvg
        meson
        ninja
        nodePackages.sass
        gtk4.dev
        optipng
      ];
      phases = ["unpackPhase" "installPhase"];
      installPhase = ''
        HOME=/build
        chmod 777 -R .
        patchShebangs .
        mkdir -p $out/share/themes
        mkdir bin
        sed -e 's/handle-horz-.*//' -e 's/handle-vert-.*//' -i ./src/gtk-2.0/assets.txt

        cat > /build/gtk-colors << EOF
          BTN_BG=${colors.primary_container}
          BTN_FG=${colors.on_primary_container}
          BG=${colors.surface}
          FG=${colors.on_surface}
          HDR_BTN_BG=${colors.secondary_container}
          HDR_BTN_FG=${colors.on_secondary_container}
          ACCENT_BG=${colors.primary}
          ACCENT_FG=${colors.on_primary}
          HDR_BG=${colors.surface_bright}
          HDR_FG=${colors.on_surface}
          MATERIA_SURFACE=${colors.surface_bright}
          MATERIA_VIEW=${colors.surface_dim}
          MENU_BG=${colors.surface_container}
          MENU_FG=${colors.on_surface}
          SEL_BG=${colors.primary_fixed_dim}
          SEL_FG=${colors.on_primary}
          TXT_BG=${colors.primary_container}
          TXT_FG=${colors.on_primary_container}
          WM_BORDER_FOCUS=${colors.outline}
          WM_BORDER_UNFOCUS=${colors.outline_variant}
          UNITY_DEFAULT_LAUNCHER_STYLE=False
          NAME=${name}
          MATERIA_STYLE_COMPACT=True
        EOF

        echo "Changing colours:"
        ./change_color.sh -o ${name} /build/gtk-colors -i False -t "$out/share/themes"
        chmod 555 -R .
      '';
    };
in rec {
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = config.i3scaling.gtkFontSize;
    };
    theme = let
      # inherit (config.colorscheme) mode colors;
      # name = "generated-${hashString "md5" (toJSON colors)}-${mode}";
      name = "generated-${hashString "md5" (toJSON colors)}";
    in {
      inherit name;
      package = materiaTheme name (
        lib.mapAttrs (_: v: lib.removePrefix "#" v) colors
      );
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Hackneyed";
      size = config.i3scaling.cursorSize;
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
      "Xft/Antialias" = true;
      "Xft/DPI" = config.i3scaling.dpi * 1024;
      "Xcursor/size" = config.i3scaling.cursorSize;
      "Xcursor/theme" = "Hackneyed";
    };
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
}
