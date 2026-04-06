{...}: {
  programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      settings.auto_reload_on_write = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<cr>";
        options.desc = "Toggle file tree";
      }
    ];
  };
}
