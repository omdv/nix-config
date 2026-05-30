{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSStubListener = "yes";
      MulticastDNS = "yes";
      Domains = ["~."];
      FallbackDNS = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
      ];
    };
  };
}
