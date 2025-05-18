{
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
    defaultGateway = "192.168.1.1";
    nameservers = [
      "192.168.1.1"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

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
}
