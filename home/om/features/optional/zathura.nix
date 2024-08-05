{ config, ... }: let
  inherit (config.colorscheme) colors;
in {
  programs.zathura = {
    enable = true;
    options = {
      default-bg = colors.surface;
      default-fg = colors.on_surface;
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = ["zathura.desktop"];
  };
}
