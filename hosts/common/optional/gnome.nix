{
  pkgs,
  lib,
  ...
}: {
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # Disable tracker
  systemd.services."tracker-miner-fs-3".enable = lib.mkForce false;
}
