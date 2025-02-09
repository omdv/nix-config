{ pkgs, config, ... }: {
  environment.systemPackages = [
    pkgs.k3s
  ];

  # add k3s user and group
  users.groups.k3s = {};
  users.users.k3s = {
    group = "k3s";
    uid = 1100;
  };

  # enable k3s service with tailscale support
  # use --flannel-backend=vxlan for conventional k3s networking
  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.symlinkJoin {
      name = "k3s-with-deps";
      paths = [ pkgs.k3s pkgs.tailscale ];
    };
    extraFlags = toString [
      "--disable traefik"
      "--disable metrics-server"
      "--tls-san=${config.networking.interfaces.tailscale0.ipv4.addresses.0.address}"
      "--tls-san=${config.networking.interfaces.enp2s0.ipv4.addresses.0.address}"
      "--tls-san=127.0.0.1"
      "--vpn-auth-file=/run/user-secrets/k3s_tailscale_auth"
      "--node-external-ip=${config.networking.interfaces.tailscale0.ipv4.addresses.0.address}"
    ];
    environmentFile = pkgs.writeText "k3s-environment" ''
      PATH=${pkgs.tailscale}/bin:$PATH
    '';
  };

  # open the k3s ports for the cluster
  # TODO: check if qbittorrent is needed
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
