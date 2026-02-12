{ pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    gnome-keyring
    seahorse
    libsecret
    libgnome-keyring
  ];
  services.gnome-keyring = {
    enable = false;
    components = [
      "pkcs11"
      "secrets"
    ];
  };
  services.pass-secret-service = {
    enable = true;
    storePath = lib.mkForce "${config.home.homeDirectory}/.password-store";
  };

  xdg = {
    desktopEntries = {
      seahorse = {
        name = "Seahorse";
        genericName = "OS keyring GUI";
        comment = "Interface for the system keyring.";
        exec = "seahorse";
        icon = "seahorse";
        terminal = false;
        categories = [
          "System"
          "Security"
        ];
        type = "Application";
      };
    };
  };
}
