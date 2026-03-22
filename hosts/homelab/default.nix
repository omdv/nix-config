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

    ../common/optional/k3s.nix
    ../common/optional/samba.nix
    ../common/optional/zfs-base.nix

    # Monitoring
    ../common/monitoring/system-notifications.nix
    ../common/monitoring/smartd.nix
    ../common/monitoring/zfs-scrub.nix
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
    backup_passphrase = mkSecret {
      name = "backup_passphrase";
      sopsFile = ./secrets.yaml;
    };
    samba_password = mkSecret {
      name = "samba_password";
      sopsFile = ./secrets.yaml;
    };
    ntfy_system_topic = mkSecret {
      name = "ntfy_system_topic";
      sopsFile = ./secrets.yaml;
    };
  };

  system.stateVersion = "23.05";
}
