{pkgs, ...}: {
  fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.open-sans
      pkgs.fira-sans
      pkgs.nerd-fonts.fira-mono
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.symbols-only
      pkgs.font-awesome
      pkgs.fontconfig
    ];

  home.sessionVariables = {
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.fontconfig.lib}/lib";
  };

  fontProfiles = {
    enable = true;
    monospace = {
      family = "FiraCode Nerd Font Mono";
      package = pkgs.nerd-fonts.fira-mono;
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira-sans;
    };
    icons = {
      family = "Symbols Nerd Font";
      package = pkgs.nerd-fonts.symbols-only;
    };
  };
}
