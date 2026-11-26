{
  colors,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/cli/bat.nix
    ./features/cli/fzf.nix
    ./features/cli/git.nix
    ./features/cli/nixvim
    ./features/cli/starship.nix
  ];

  colorscheme = colors.colorSchemes.catppuccin-mocha;
  home.packages = with pkgs; [eza fd jq ripgrep];
  # The standalone global module and NixOS integration both select Nix.
  nix.package = lib.mkForce pkgs.nix;

  # Personal Fish functions depend on credentials and native host management.
  programs.fish = {
    enable = true;
    interactiveShellInit = "set -g fish_greeting";
  };
  programs.fzf.enableFishIntegration = lib.mkForce true;

  # This disposable guest has no private signing key or local flake checkout.
  programs.git.signing.signByDefault = lib.mkForce false;
  programs.git.settings.commit.gpgSign = false;
  programs.nixvim.plugins.lsp.servers.nixd.enable = lib.mkForce false;
}
