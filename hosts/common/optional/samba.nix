{
  services.samba = {
    enable = true;
    shares = {
      "pool" = {
        path = "/pool";
        writeable = true;
        browsable = true;
        guestOk = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
