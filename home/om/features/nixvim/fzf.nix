{ ... }: {
  programs.nixvim.plugins.fzf-lua = {
    enable = true;
    keymaps = {
      # Files
      "<leader>ff" = { action = "files";      options.desc = "Find files"; };
      "<leader>fg" = { action = "git_files";  options.desc = "Find git files"; };
      "<leader>fr" = { action = "oldfiles";   options.desc = "Recent files"; };

      # Search
      "<leader>fw" = { action = "live_grep";  options.desc = "Live grep"; };
      "<leader>fs" = { action = "grep_cword"; options.desc = "Grep word under cursor"; };

      # Buffers / UI
      "<leader>fb" = { action = "buffers";    options.desc = "Find buffers"; };
      "<leader>fh" = { action = "helptags";   options.desc = "Help tags"; };

      # LSP
      "<leader>fd" = { action = "lsp_document_symbols";  options.desc = "Document symbols"; };
      "<leader>fD" = { action = "lsp_workspace_symbols"; options.desc = "Workspace symbols"; };
    };
  };
}
