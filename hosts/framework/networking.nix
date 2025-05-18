{ lib, ... }: {
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
}
