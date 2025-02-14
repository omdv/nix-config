{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    open-iscsi
  ];
  services.openiscsi = {
    enable = true;
    name = "iqn.2025-02.rs.x9:homelab";
  };
}
