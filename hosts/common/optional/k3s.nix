{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.k3s
  ];

  services.k3s = {
    enable = true;
    role = "server";
    extraArgs = toString [
      "--disable traefik"
      "--disable metrics-server"
      "--flannel-backend=vxlan"
    ];
  };

  # open the k3s ports
  networking.firewall.allowedTCPPorts = [ 6443 ];
}
