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
      "--flannel-backend=vxlan"
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
