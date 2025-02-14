{ pkgs, ... }: {
  services.openiscsi = {
    packages = [ pkgs.openiscsi ];
    enable = true;
    openPort = 3260;
  };
}
