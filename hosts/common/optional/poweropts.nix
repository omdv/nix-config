{pkgs, ...}: {
  powerManagement.enable = true;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    powertop
    powerstat
  ];

  # powertop recommended settings
  boot = {
    kernel.sysctl = {
      "vm.dirty_writeback_centisecs" = 1500;
    };
    kernelParams = [
      "nowatchdog"
    ];
  };
}
