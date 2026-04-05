{
  inputs,
  config,
  mkSecret,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ./networking.nix

    ../common/global
    ../common/users/om

    # gaming / gpu profile
    ../common/optional/nvidia.nix
    ../common/optional/xserver.nix
    ../common/optional/i3wm.nix

    # Monitoring
    ../common/monitoring/system-notifications.nix
    ../common/monitoring/smartd.nix
  ];

  # enable lingering for systemd services
  users.users.om.linger = true;

  # allow om to inhibit systemd services
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ([
          "org.freedesktop.login1.inhibit-block-sleep",
          "org.freedesktop.login1.inhibit-block-idle",
          "org.freedesktop.login1.inhibit-block-shutdown",
        ].indexOf(action.id) >= 0 &&
        subject.user == "${config.users.users.om.name}") {
        return polkit.Result.YES;
      }
    });
  '';

  sops.secrets = {
    ntfy_system_topic = mkSecret {
      name = "ntfy_system_topic";
      sopsFile = ./secrets.yaml;
    };
  };

  system.stateVersion = "25.11";
}
