{
  programs.rtorrent = {
    enable = true;
  };
  xdg.desktopEntries = {
    rtorrent = {
      name = "rtorrent";
      genericName = "Torrent Client";
      comment = "Download torrents";
      exec = "kitty -e rtorrent";
      icon = "rtorrent";
      mimeType = [
        "x-scheme-handler/magnet"
      ];
      terminal = true;
      type = "Application";
      categories = [
        "Utility"
        "Network"
      ];
    };
  };
}
