{ pkgs, config, lib, ... }:
{
  environment.systemPackages = [
    pkgs.smartmontools
  ];

  services.smartd = {
    enable = true;
    devices = [
      (lib.mkIf (config.networking.hostName == "homelab") {
        device = "/dev/sda";
      })
      (lib.mkIf (config.networking.hostName == "homelab") {
        device = "/dev/sdb";
      })
      (lib.mkIf (config.networking.hostName == "homelab") {
        device = "/dev/sdc";
      })
      (lib.mkIf (config.networking.hostName == "homelab") {
        device = "/dev/sdd";
      })
      {
        device = "/dev/nvme0n1";
      }
    ];
  };
}
