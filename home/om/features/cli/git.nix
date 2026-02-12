{ pkgs, config, lib, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    signing = {
      key = "A125B037FB60B286";
      signByDefault = true;
    };
    settings = {
      alias = {
        p = "pull --ff-only";
        ff = "merge --ff-only";
        graph = "log --decorate --oneline --graph";
      };
      user = {
        name = "Oleg Medvedev";
        email = lib.mkDefault "omdv@protonmail.com";
        signing.key = "A125B037FB60B286";
      };
      init.defaultBranch = "main";
      commit = {
        gpgSign = lib.mkDefault true;
        verbose = true;
      };
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";
      push.autoSetupRemote = true;
      rerere.enabled = true;
    };
    lfs.enable = true;
    ignores = [
      ".direnv"
      "result"
    ];
  };
}
