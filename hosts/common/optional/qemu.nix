{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    quickemu
    samba
  ];
  # samba for sharing files with the host
  services.samba = {
    enable = true;
  };
}
