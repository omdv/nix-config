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
      enable = false;
    };
    autoScrub = {
      enable = true;
      pools = [ "pool" ];
      interval = "monthly";
    };
    autoSnapshot = {
      enable = false;
    };
  };
}
