{pkgs, ...}: let
  dockerEnabled = false;
in {
  virtualisation.containers = {
    enable = true;
    policy = {
      default = [
        {type = "insecureAcceptAnything";}
      ];
      transports = {
        docker-daemon = {
          "" = [
            {type = "insecureAcceptAnything";}
          ];
        };
      };
    };
  };

  virtualisation = {
    podman = {
      enable = !dockerEnabled;
      dockerCompat = !dockerEnabled;
      defaultNetwork.settings.dns_enabled = !dockerEnabled;
    };
    docker = {
      enable = dockerEnabled;
    };
  };

  # Various tools for podman and docker
  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];
}
