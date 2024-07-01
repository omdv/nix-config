{pkgs, ...}: {
  services.gnome-keyring.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
	enable = true;
	pinentryFlavor = "qt";
  };
}
