{ pkgs, ... }:
let
  # TODO: parameterize properly from config
  tailscaleIP = "100.105.105.100";
  lanIP = "192.168.1.98";
in {
  environment.systemPackages = [
    pkgs.k3s
  ];

  # add k3s user and group
  users.groups.k3s = {};
  users.users.k3s = {
    isSystemUser = true;
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
      "--tls-san=${tailscaleIP}"
      "--tls-san=${lanIP}"
      "--tls-san=127.0.0.1"
      "--vpn-auth-file=/run/user-secrets/k3s_tailscale_auth"
      "--node-external-ip=${tailscaleIP}"
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
