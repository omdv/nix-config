{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    theme = "Dracula";
    font = {
      name = "FiraCode Nerd Font";
      size = 16;
    };
    shellIntegration.enableFishIntegration = true;
    settings = {
      scrollback_lines = 4000;
      scrollback_pager_history_size = 100000;
      confirm_os_window_close = -0;
      copy_on_select = true;
      clipboard_control = "write-clipboard read-clipboard write-primary read-primary";

      # for nnn
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      enabled_layouts = "all";
    };
  };
}