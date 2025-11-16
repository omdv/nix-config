{
  services.samba = {
    enable = true;
    openFirewall = true;
    users = {
      "samba" = {
        passwordFile = "/run/user-secrets/samba-password";
      };
    };
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
      "pool" = {
        path = "/pool";
        "writeable" = "yes";
        "browsable" = "yes";
        "guest ok" = "no";
        "valid users" = [ "samba" ];
      };
    };
  };
}
