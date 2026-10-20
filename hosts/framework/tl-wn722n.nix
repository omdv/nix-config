{pkgs, ...}: {
  boot.kernelModules = ["ath9k_htc"];

  hardware.enableRedistributableFirmware = true;

  # Reserve this adapter for monitor mode and packet injection.
  networking.networkmanager.unmanaged = ["mac:10:fe:ed:26:c7:d6"];

  environment.systemPackages = with pkgs; [
    aircrack-ng
    iw
    usbutils
  ];
}
