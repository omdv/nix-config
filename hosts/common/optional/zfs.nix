{ pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs = {
    # TODO: enable mail
    zed = {
      enableMail = false;
    };
    trim = {
      enable = true;
      interval = "weekly";
    };
    autoScrub = {
      enable = true;
      pools = [ "pool" ];
      interval = "weekly";
    };
    autoSnapshot = {
      enable = false;
    };
  };
}
