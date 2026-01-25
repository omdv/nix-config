{pkgs, ...}: let
  fzf-preview = pkgs.writeShellScriptBin "fzf-preview" ''
    if [ -d "$1" ]; then
      ${pkgs.eza}/bin/eza --tree --level=2 --color=always "$1"
    else
      ${pkgs.bat}/bin/bat --color=always --style=numbers "$1"
    fi
  '';
in {
  programs.fzf = {
    enable = true;
    enableFishIntegration = false; # fzf.fish plugin handles this
    defaultOptions = [
      "--inline-info"
      "--color 16"
      "--height 100%"
      "--preview '${fzf-preview}/bin/fzf-preview {}'"
    ];
  };

  home.packages = [fzf-preview];
}
