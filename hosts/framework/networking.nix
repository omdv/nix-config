{
  lib,
  pkgs,
  ...
}: let
  mkScript = {
    name ? "script",
    deps ? [],
    script ? "",
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = script;
      runtimeInputs = deps;
    });
in {
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
    ];
    domains = [ "~." ];
    extraConfig = ''
      DNSStubListener=yes
    '';
  };

  networking = {
    hostName = "framework";
    networkmanager.enable = true;
    useNetworkd = false;
  };

  # Configure NetworkManager to use specific DNS for VPN connections
  networking.networkmanager.dispatcherScripts = [
    {
      source = mkScript {
        deps = [ pkgs.coreutils pkgs.systemd ];
        script = ''
IFACE="$1"
STATUS="$2"

if [[ "$STATUS" != "up" ]]; then
  exit 0
fi

case "$IFACE" in
  wg0-mullvad)
    resolvectl dns "$IFACE" 193.138.218.74 185.213.154.45
    resolvectl domain "$IFACE" "~."
    ;;
  tailscale0)
    resolvectl dns "$IFACE" 100.100.100.100
    resolvectl domain "$IFACE" "ts.net"
    ;;
esac
        '';
      };
    }
];
}
