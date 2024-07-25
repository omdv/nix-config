{pkgs, ...}: {
  programs.gpg.enable = true;

  services.gpg-agent = {
	  enable = true;
    enableFishIntegration = true;
	  pinentryPackage = pkgs.pinentry-curses;
  };
}
