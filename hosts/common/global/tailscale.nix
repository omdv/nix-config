{
  services.tailscale = {
    enable = true;
    port = 41414;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-dns=false"
      "--accept-routes=false"
    ];
  };

  networking.firewall.allowedUDPPorts = [41414];
}
