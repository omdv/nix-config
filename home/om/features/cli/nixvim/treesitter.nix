{config, ...}: {
  programs.nixvim.plugins.treesitter = {
    enable = true;
    highlight.enable = true;
    indent.enable = true;
    grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
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
