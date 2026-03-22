{pkgs, ...}: {
  programs.nixvim.plugins.treesitter = {
    enable = true;
    settings.highlight.enable = true;
    settings.indent.enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      nix
      python
      lua
      bash
      json
      yaml
      toml
      markdown
      markdown_inline
    ];
  };
}
