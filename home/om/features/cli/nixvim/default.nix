{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./settings.nix
    ./bufferline.nix
    ./css-color.nix
    ./cursorline.nix
    ./fzf.nix
    ./nvim-tree.nix
    ./statusline
    ./web-devicons.nix
    ./which-key.nix
    ./treesitter.nix
    ./lsp.nix
    ./conform.nix
    ./completion.nix
    ./gitsigns.nix
    ./indent-blankline.nix
  ];

  programs.nixvim = {
    enable = true;
  };

  home.sessionVariables.EDITOR = "nvim";
}
