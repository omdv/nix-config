{ pkgs, ... }:
{
  users.users.om = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "docker"
      "wheel"
      "libvirtd"
    ];
  };
}
