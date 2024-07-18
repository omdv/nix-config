{pkgs, ...}: {
  fonts.fontconfig.enable = true;
    home.packages = [
      (pkgs.nerdfonts.override {
        fonts = [
          "FiraCode"
          "NerdFontsSymbolsOnly"
        ];
      })
      pkgs.font-awesome
    ];

  fontProfiles = {
    enable = true;
    monospace = {
      family = "FiraCode Nerd Font";
      package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
    icons = {
      # family = "Symbols Nerd Font";
      # package = pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];};
      family = "Font Awesome";
      package = pkgs.font-awesome;
    };
  };
}
