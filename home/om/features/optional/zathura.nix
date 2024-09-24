{ config, ... }: let
  inherit (config.colorscheme) colors;
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
