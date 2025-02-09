{lib, ...}: {
  services.tailscale = {
    enable = true;
    port = 41414;
    useRoutingFeatures = lib.mkDefault "client";
    # extraUpFlags = [
    #   "--login-server tailscale.${config.networking.domain}"
    #   ];
  };

  # firewall punching
  networking.firewall.allowedUDPPorts = [41414];
}
