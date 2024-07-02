{pkgs, ...}:
{
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome = {
        enable = true;
      };
      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    gnome3.gnome-tweaks
  ];

}
