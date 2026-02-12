{ lib, pkgs, ... }: {
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
    ];
    domains = [ "~." ];
    extraConfig = ''
      DNSStubListener=yes
    '';
  };

  networking = {
    hostName = "framework";
    useNetworkd = false;
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
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
