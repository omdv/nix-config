{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    openiscsi
  ];
  services.openiscsi = {
    enable = true;
    name = "iqn.2025-02.rs.x9:homelab";
  };

  # Bind mount nsenter to /usr/bin for k3s longhorn compatibility
  system.activationScripts.nsenter = ''
    mkdir -p /usr/bin
    ln -sfn ${pkgs.util-linux}/bin/nsenter /usr/bin/nsenter
  '';

  # Bind mount iscsiadm to /usr/bin for k3s longhorn compatibility
  system.activationScripts.iscsiadm = ''
    mkdir -p /usr/bin
    ln -sfn ${pkgs.openiscsi}/bin/iscsiadm /usr/bin/iscsiadm
  '';
}
