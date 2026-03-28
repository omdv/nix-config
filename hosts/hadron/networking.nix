{
  lib,
  pkgs,
  ...
}: {
  networking = {
    hostId = "35f9f50f";
    hostName = "hadron";
    useNetworkd = false;
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
    };
  };

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
    ];
    domains = ["~."];
    extraConfig = ''
      DNSStubListener=yes
    '';
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

  networking.firewall.trustedInterfaces = ["tailscale0"];
}
