{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    theme = "Dracula";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
    shellIntegration.enableFishIntegration = true;
    settings = {
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
