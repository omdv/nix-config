{ pkgs, config, ... }: {
  environment.systemPackages = [
    pkgs.k3s
  ];

  services.k3s = {
    enable = false;
    role = "server";
    extraFlags = toString [
      "--disable traefik"
      "--disable metrics-server"
      "--flannel-backend=vxlan"
      "--tls-san=${config.networking.hostName}.ts.x9.rs"
      "--tls-san=192.168.1.98"
      "--tls-san=127.0.0.1"
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
