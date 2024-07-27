{ pkgs, ... }: {
  home.packages = with pkgs; [
    gnome.gnome-keyring
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

  # security.pam.services.lightdm = {
  #   enable = true;
  #   text = ''
  #     auth optional pam_gnome_keyring.so
  #     session optional pam_gnome_keyring.so auto_start
  #   '';
  # };
}
