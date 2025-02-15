{ pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = false;
  };

  # mount longhorn storage pool to zfs
  fileSystems."/var/lib/longhorn" = {
    device = "pool/longhorn";
    fsType = "zfs";
  };
}
