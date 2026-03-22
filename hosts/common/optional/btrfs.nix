{lib, ...}: {
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  # Prevent scrub from firing at boot when the window was missed
  systemd.timers."btrfs-scrub--" = {
    timerConfig.Persistent = lib.mkForce false;
  };
}
