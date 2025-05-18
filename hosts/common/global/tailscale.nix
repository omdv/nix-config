{
  services.tailscale = {
    enable = true;
    port = 41414;
    openFirewall = true;
    extraSetFlags = [
      "--accept-dns=true"
      "--accept-routes=false"
    ];
  };

  systemd.services.tailscaled.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "20s";
  };
}
