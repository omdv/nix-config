{inputs, ...}: {
  imports = [
    inputs.bootvine.nixosModules.default
  ];

  services.bootvine.enable = true;

  console = {
    useXkbConfig = true;
    earlySetup = false;
  };

  boot = {
    initrd.systemd.enable = true;

    plymouth.enable = false;

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
