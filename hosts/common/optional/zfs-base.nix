# ZFS filesystem base configuration
# For monitoring/scrub setup, see ../monitoring/zfs-scrub.nix
{pkgs, ...}: {
  environment.systemPackages = [pkgs.zfs];

  services.zfs = {
    # Monitoring handled by monitoring/zfs-scrub.nix
    trim.enable = false;
    autoSnapshot.enable = false;
  };
}
