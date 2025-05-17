{
  services.tailscale = {
    enable = true;
    port = 41414;
    useRoutingFeatures = "both";
    extraUpFlags = [ "--accept-dns=false" ];
  };

  networking.firewall.allowedUDPPorts = [41414];
}
