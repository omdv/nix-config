{
  programs.nixvim = {
    plugins.fzf-lua = {
      enable = true;
      keymaps = {
        "<C-p>" = "git_files";
        "<leader>fg" = "live_grep";
      };
    };
  };
}
