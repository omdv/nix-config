{ pkgs-unstable, ... }: {
  networking = {
    hostId = "c6589261";
    hostName = "homelab";
    useNetworkd = true;
    interfaces = {
      enp2s0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.1.98";
          prefixLength = 24;
        }];
      };
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp2s0";
    };
    nameservers = [
      "192.168.1.1"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

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

  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
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

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
