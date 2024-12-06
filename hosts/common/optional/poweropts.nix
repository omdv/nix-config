{ pkgs, lib, ... }: {


  powerManagement.enable = true;

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=no
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=1h
    HandleLidSwitch=suspend-then-hibernate
    HandleLidSwitchExternalPower=ignore
    IdleAction=hibernate
    IdleActionSec=30min
  '';

  # # glibc is needed for auto-cpufreq
  # environment.systemPackages = with pkgs; [
  #   glibc
  # ];

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
}
