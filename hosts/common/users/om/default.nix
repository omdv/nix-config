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

  # # allow inhibit explicitly for borgmatic
  # security.polkit = {
  #   enable = true;
  #   extraConfig = ''
  #     polkit.addRule(function(action, subject) {
  #       if (subject.user == "om") {
  #         if ([
  #           "org.freedesktop.login1.inhibit-block-shutdown",
  #           "org.freedesktop.login1.inhibit-block-sleep",
  #           "org.freedesktop.login1.inhibit-delay-shutdown",
  #           "org.freedesktop.login1.inhibit-delay-sleep",
  #         ].indexOf(action.id) != -1) {
  #           return polkit.Result.YES;
  #         }
  #       }
  #     });
  #   '';
  # };
}
