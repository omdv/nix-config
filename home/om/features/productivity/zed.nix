{
  programs.zed-editor = {
    enable = true;
    userSettings = {
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
      show_whitespaces = "selection";
      ui_font_family = "FiraCode Nerd Font";
      ui_font_size = 20;
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_size = 20;
      agent_font_family = "FiraCode Nerd Font";
      agent_font_size = 20;
      agent = {
        enabled = true;
        version = "2";
        default_model = {
          provider = "google";
          model = "gemini-2.0-flash";
          default_open_ai_model = "null";
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
