{ config, ... }: let
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
  programs.zathura = {
    enable = true;
    options = {
      default-bg = colors.surface;
      default-fg = colors.on_surface;
      database = "sqlite";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
  };
}
