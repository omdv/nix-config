{pkgs, ...}: {
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;
    enableFishIntegration = false;
    settings = {
      theme = "catppuccin-mocha";
      show_release_notes = false;
      default_mode = "locked";
    };
  };
}
