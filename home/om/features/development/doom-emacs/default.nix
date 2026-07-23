{pkgs, ...}: {
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom;
    emacs = pkgs.emacs-pgtk;
    experimentalFetchTree = true;
    extraPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars
    ];
  };
}
