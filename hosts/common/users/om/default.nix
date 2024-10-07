{
  pkgs,
  config,
  lib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.om = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "audio"
      "docker"
      "git"
      "libvirtd"
      "lxd"
      "network"
      "podman"
      "video"
      "wheel"
      "wireshark"
    ];

    packages = [pkgs.home-manager];
    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../../../home/om/ssh.pub);
  };

  # gnome-keyring
  security = {
    pam.services = {
      login.enableGnomeKeyring = true;
      lightdm.enableGnomeKeyring = true;
    };
  };

  # allow inhibit explicitly for borgmatic
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd-inhibit" &&
            subject.user == "om") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
