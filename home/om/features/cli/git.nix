{ pkgs, config, lib, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      p = "pull --ff-only";
      ff = "merge --ff-only";
      graph = "log --decorate --oneline --graph";
    };
    signing = {
      key = "A125B037FB60B286";
      signByDefault = true;
    };
    userName = "Oleg Medvedev";
    userEmail = lib.mkDefault "omdv@protonmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      user.signing.key = "A125B037FB60B286";
      commit.gpgSign = lib.mkDefault true;
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";

      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
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
