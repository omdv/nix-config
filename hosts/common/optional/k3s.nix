{ pkgs, config, ... }: {
  environment.systemPackages = [
    pkgs.k3s
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable traefik"
      "--disable metrics-server"
      "--flannel-backend=vxlan"
      "--tls-san=${config.networking.hostName}.ts.hut.sh"
      "--tls-san=${config.networking.interfaces.enp2s0.ipv4.addresses.0.address}"
      "--tls-san=127.0.0.1"
    ];
  };

  # open the k3s ports for the cluster
  networking.firewall.allowedTCPPorts = [
    80
    443
    6443    # k3s
    32400   # plex
  ];
}
