# TODO: add flavors, once they are available in stable home-manager
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        ratio = [1 3 4];
        sort_by = "natural";
        sort_dir_first = true;
        show_hidden = true;
        show_symlink = true;
        linemode = "size";
      };
    };
  };
}
