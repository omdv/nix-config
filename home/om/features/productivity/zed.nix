{
  programs.zed-editor = {
    enable = true;
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
      ui_font_size = 22;
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_size = 22;
      agent_font_family = "FiraCode Nerd Font";
      agent_font_size = 22;
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
}
