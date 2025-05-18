{
  networking = {
    hostId = "c6589261";
    hostName = "homelab";
    useDHCP = true;
    interfaces = {
      enp2s0 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = "192.168.1.98";
          prefixLength = 24;
        }];
      };
    };
  };
}
