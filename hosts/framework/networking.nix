{
  lib,
  pkgs,
  ...
}: {
  networking = {
    hostName = "framework";
    useNetworkd = false;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };

  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
    port = 41414;
    openFirewall = true;
    extraSetFlags = [
      "--accept-dns=true"
      "--accept-routes=true"
    ];
  };

  systemd.services.tailscaled.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "20s";
  };
}
