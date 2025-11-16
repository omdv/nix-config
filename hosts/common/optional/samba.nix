{
  users.users.samba = {
    isSystemUser = true;
    group = "samba";
    description = "Samba user";
  };
  users.groups.samba = {};

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
      "pool" = {
        path = "/pool";
        "writeable" = "yes";
        "browsable" = "yes";
        "guest ok" = "no";
        "valid users" = "samba";
      };
    };
  };
}
