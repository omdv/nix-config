{ pkgs, ... }: {

  # # requirement for vpn
  # services.resolved = {
  #   enable = true;
  #   dnssec = "true";
  #   domains = [ "~." ];
  #   fallbackDns = [
  #     "1.1.1.1"
  #     "1.0.0.1"
  #     "8.8.8.8"
  #   ];
  #   dnsovertls = "true";
  # };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
}
