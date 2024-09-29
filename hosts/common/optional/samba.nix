{
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    shares = {
      "scanned_files" = {
        path = "/pool/documents/scanned_files";
        writeable = true;
        browsable = true;
        guestOk = true;
      };
    };
  };
}
