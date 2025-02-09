{ config, ... }:
  let
    domain = "ts.x9.rs";
    port = 8000;
  in {
    services = {
      headscale = {
      enable = true;
      port = port;
      address = "0.0.0.0";
      settings = {
        dns = {
          base_domain = domain;
          magic_dns = true;
          nameservers = {
            global = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };
        };
        server_url = "https://${domain}";
        metrics_listen_addr = "127.0.0.1:9095";
        logtail = {
          enabled = false;
        };
        log = {
          level = "warn";
        };
        ip_prefixes = [
          "100.77.0.0/24"
          "fd7a:115c:a1e0:77::/64"
        ];
        derp.server = {
          enable = false;
        };
      };
    };

    nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
        "/metrics" = {
          proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
  environment.systemPackages = [config.services.headscale.package];

}
