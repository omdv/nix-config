{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.k3s
  ];

  services.k3s = {
    enable = true;
    extraArgs = ''
      --no-deploy traefik
      --no-deploy metrics-server
      --flannel-backend=vxlan
    '';
  };
}
