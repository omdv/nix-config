{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.colorscheme) colors harmonized;
in {
  home.packages = [
    (
      pkgs.writeShellScriptBin "xterm" ''
        ${lib.getExe config.programs.kitty.package} "$@"
      ''
    )
  ];
  # I prefer to use ssh -M explicitly, thanks.
  xdg.configFile."kitty/ssh.conf".text = ''
    share_connections no
  '';
  xdg.mimeApps = {
    associations.added = {
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
  };
  programs.kitty = {
    enable = true;
    font = {
      name = config.fontProfiles.monospace.family;
      size = 14;
    };
    keybindings = {
      "ctrl+enter" = "send_text normal clone-in-kitty --type os-window\\r";
    };
    settings = {
      editor = config.home.sessionVariables.EDITOR;
      shell_integration = "no-rc"; # I prefer to do it manually
      scrollback_lines = 4000;
      scrollback_pager_history_size = 100000;
      window_padding_width = 15;
      theme = "Dracula";

      # for nnn
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      enabled_layouts = "all";
    };
  };
}
