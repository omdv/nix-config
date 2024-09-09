{ pkgs, ... }: {
  home.packages = with pkgs; [
    zed-editor
  ];
  xdg.configFile."zed/settings.json".text =
    ''
    {
      "theme": {
        "mode": "system",
        "dark": "Dracula",
        "light": "Dracula"
      },
      "vim_mode": false,
      "ui_font_size": 20,
      "buffer_font_size": 20,
      "assistant": {
          "enabled": true,
          "default_model": {
            "provider": "zed.dev",
            "model": "claude-3-5-sonnet"
          },
          "version": "2",
          "button": true,
          "default_width": 480,
          "dock": "right"
        }
    }
    '';
  }
