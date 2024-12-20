{ config, ... }: let
  colors = config.colorscheme.palette;
in {
  programs.zathura = {
    enable = true;
    options = {
      default-bg = colors.base00;
      default-fg = colors.base06;
      database = "sqlite";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = ["org.pwmt.zathura-pdf-mupdf.desktop"];
  };
}
