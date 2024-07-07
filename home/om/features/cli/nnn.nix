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
        sha256 = "sha256-g19uI36HyzTF2YUQKFP4DE2ZBsArGryVHhX79Y0XzhU=";
      }) + "/plugins";
    };
  };
}
