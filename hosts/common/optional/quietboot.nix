{
  pkgs,
  config,
  ...
}: {
  console = {
    useXkbConfig = true;
    earlySetup = false;
  };

  boot = {
    initrd.systemd.enable = true;

    plymouth = {
      enable = true;
      theme = "cubes";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "cubes" ];
        })
      ];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "vt.global_cursor_default=0"
    ];
    loader.timeout = 5;
  };
}
