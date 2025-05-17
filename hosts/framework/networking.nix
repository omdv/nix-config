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
    useNetworkd = false;
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
      dispatcherScripts = [
        {
          source = mkScript {
            deps = [ pkgs.coreutils pkgs.systemd pkgs.networkmanager ];
            script = ''
              IFACE="$1"
              STATE="$2"

              echo "Dispatcher fired: $1 $2 at $(date)" >> /tmp/nm-dispatcher.log

              if [ "$STATE" != "up" ]; then
                exit 0
              fi

              if [ "$STATE" = "up" ]; then
                echo "Ignoring DHCP-provided DNS on $IFACE" >> /tmp/nm-dispatcher.log
                nmcli device modify "$IFACE" ipv4.ignore-auto-dns yes
                nmcli device modify "$IFACE" ipv6.ignore-auto-dns yes
              fi

              case "$IFACE" in
                wg0-mullvad)
                  echo "Mullvad interface is up." >> /tmp/nm-dispatcher.log
                  resolvectl dns "$IFACE" 193.138.218.74 185.213.154.45
                  resolvectl domain "$IFACE" "~."
                  resolvectl status "$IFACE" >> /tmp/nm-dispatcher.log
                  ;;
                tailscale0)
                  echo "Tailscale interface is up." >> /tmp/nm-dispatcher.log
                  resolvectl dns "$IFACE" 100.100.100.100
                  resolvectl domain "$IFACE" "ts.net"
                  resolvectl status "$IFACE" >> /tmp/nm-dispatcher.log
                  ;;
                *)
                  echo "Unknown interface: $IFACE" >> /tmp/nm-dispatcher.log
                  ;;
              esac
            '';
          };
        }
      ];
    };
  };
}
