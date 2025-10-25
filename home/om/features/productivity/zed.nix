{ pkgs-unstable, ... }: {
  home.packages = [ pkgs-unstable.zed-editor ];

# TODO
# Add claude support
# Improve prediction model
# Add support for other languages
# Add support for more file types

  # Old home-manager config preserved below for reference:
  /*
  programs.zed-editor = {
    package = pkgs-unstable.zed-editor;
    enable = true;
    extensions = [ "nix" "toml" "python" ];
    userSettings = {
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Catppuccin Mauve";
      };
      lsp = {
        nix = {
          binary.path_lookup = true;
        };
      };
      show_whitespaces = "selection";
      ui_font_family = "FiraCode Nerd Font";
      ui_font_size = 12;
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_size = 12;
      agent_font_family = "FiraCode Nerd Font";
      agent_font_size = 12;
      agent = {
        enabled = true;
        version = "2";
        default_open_ai_model = "null";
        default_model = {
          provider = "google";
          model = "gemini-2.0-flash";
        };
        inline_assistant_model = {
          provider = "google";
          model = "gemini-2.0-flash";
        };
        commit_message_model = {
          provider = "google";
          model = "gemini-2.0-flash";
        };
        thread_summary_model = {
          provider = "google";
          model = "gemini-2.0-flash";
        };
      };
      auto_update = false;
    };
  };
  */
}
