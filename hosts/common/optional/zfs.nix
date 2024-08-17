{ pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zfs
  ];


  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = false;
  };
}