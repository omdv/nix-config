{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["org.qutebrowser.qutebrowser.desktop"];
    "text/xml" = ["org.qutebrowser.qutebrowser.desktop"];
    "text/qute" = ["org.qutebrowser.qutebrowser.desktop"];
    "x-scheme-handler/qute" = ["org.qutebrowser.qutebrowser.desktop"];
  };

  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    settings = {
      downloads.open_dispatcher = "${lib.getExe pkgs.handlr-regex} open {}";
      editor.command = ["${lib.getExe pkgs.handlr-regex}" "open" "{file}"];
      tabs = {
        show = "multiple";
        position = "left";
        indicator.width = 0;
      };
      fonts = {
        default_family = config.fontProfiles.regular.family;
        default_size = "12pt";
      };
    };
    extraConfig = ''
      c.tabs.padding = {"bottom": 10, "left": 10, "right": 10, "top": 10}
    '';
  };

  xdg.configFile."qutebrowser/config.py".onChange = lib.mkForce ''
    ${pkgs.procps}/bin/pkill -u $USER -HUP qutebrowser || true
  '';
}
