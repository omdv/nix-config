# Baofeng radio programming
{ pkgs, ... }: {
  home.packages = [
    pkgs.chirp
  ];

  xdg.desktopEntries = {
    chirp = {
      name = "chirp";
      genericName = "Baofeng Radio Programming";
      comment = "Baofeng Radio Programming";
      exec = "chirp";
      icon = "chirp";
      terminal = false;
      type = "Application";
      categories = [
        "Utility"
        "HamRadio"
      ];
    };
  };
}
