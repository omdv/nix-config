{...}: {
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings = {
      preset = "classic";
      delay = 300;

      icons = {
        mappings = true;
        breadcrumb = "»";
        separator = "➜";
        group = "+";
      };

      win = {
        no_overlap = true;
        padding = [1 2];
        title = true;
        title_pos = "center";
      };

      plugins = {
        marks = true;
        registers = true;
        spelling = {
          enabled = true;
          suggestions = 20;
        };
        presets = {
          operators = true;
          motions = true;
          text_objects = true;
          windows = true;
          nav = true;
          z = true;
          g = true;
        };
      };
    };
  };
}
