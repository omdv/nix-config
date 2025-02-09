{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.k3s
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable traefik"
      "--disable metrics-server"
      # "--flannel-backend=vxlan"
      # "--tls-san=100.105.86.80" # tailscale
      # "--tls-san=192.168.1.98"  # lan
      # "--tls-san=127.0.0.1"
      "--vpn-auth-file=/run/user-secrets/k3s_tailscale_auth"
      "--node-external-ip=100.105.100.100"
    ];
  };

  # open the k3s ports for the cluster
  networking.firewall.allowedTCPPorts = [
    80
    443
    6443    # k3s
    32400   # plex
    18289   # qbittorrent
  ];

  networking.firewall.allowedUDPPorts = [
    18289   # qbittorrent
  ];
}
