{pkgs,config, ...}: let
  dockerEnabled = false;
in {
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;

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
