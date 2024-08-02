{
  programs.nixvim = {
    plugins.fzf-lua = {
      enable = true;
      keymaps = {
        "<C-g>" = "git_files";
        "<C-f>" = "live_grep";
      };
    };
  };
}
