{pkgs, ...}: {
  imports = [../../../../../modules/home-manager/fonts.nix];

  fontProfiles = {
    enable = true;
    monospace = {
      family = "FiraCode Nerd Font Mono";
      package = pkgs.nerd-fonts.fira-code;
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
