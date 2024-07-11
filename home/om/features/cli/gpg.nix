{pkgs, ...}: {
  services.gnome-keyring.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
	enable = true;
	# pinentryPackage = pkgs.pinentry-gnome3;
	pinentryPackage = pkgs.pinentry-curses;
  };
}
