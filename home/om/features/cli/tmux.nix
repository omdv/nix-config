{pkgs, ...} : {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    aggressiveResize = true;
    clock24 = true;
    shell = "${pkgs.fish}/bin/fish";
  };
}
