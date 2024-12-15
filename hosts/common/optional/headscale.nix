{ config, ... }:
  let domain = "tailscale.hut.sh";
in {
  services = {
    headscale = {
      enable = true;
      port = 8000;
      address = "0.0.0.0";
      settings = {
        dns_config = {
          override_local_dns = true;
          nameservers = [
            "1.1.1.1"
            "1.0.0.1"
          ];
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

  environment.systemPackages = [config.services.headscale.package];

}
