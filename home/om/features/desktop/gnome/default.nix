{
  config,
  ...
}: {
  imports = [
    ../common
  ];
  # Scaling in GNOME
  dconf.settings."org/gnome/desktop/interface".text-scaling-factor = 1.28;
  dconf.settings."org/gnome/desktop/background".picture-uri-dark = config.wallpaper.url;
}
