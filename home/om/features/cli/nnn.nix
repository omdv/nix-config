{ pkgs, ... }: {
  programs.nnn = {
    enable = true;
    bookmarks = {
      "d" = "~/Documents";
      "D" = "~/Downloads";
      "p" = "~/Pictures";
      "v" = "~/Videos";
    };
    plugins = {
      src = (pkgs.fetchFromGitHub {
      owner = "jarun";
      repo = "nnn";
      rev = "v4.9";
      sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
      }) + "/plugins";
      mappings = {
        "^p" = "preview-tabbed";
        "^t" = "trash";
        "^y" = "yank";
      };
    };
  };
}
