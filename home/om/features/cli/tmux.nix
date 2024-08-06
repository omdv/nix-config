{pkgs, ...} : {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    prefix = "C-a";
    aggressiveResize = true;
    clock24 = true;
    shell = "${pkgs.fish}/bin/fish";
    sensibleOnTop = true;
  };
}
