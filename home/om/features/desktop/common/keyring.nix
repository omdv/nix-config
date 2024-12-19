{ pkgs, ... }: {
  home.packages = with pkgs; [
    gnome-keyring
    seahorse
    libsecret
    libgnome-keyring
  ];
  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
    ];
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
