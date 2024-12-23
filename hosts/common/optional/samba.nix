{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
      };
      "scanned_files" = {
        path = "/pool/documents/scanned_files";
        "writeable" = "yes";
        "browsable" = "yes";
        "guest ok" = "yes";
      };
    };
  };
}
