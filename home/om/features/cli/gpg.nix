{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    settings = {};
  };

  services.gpg-agent = {
	  enable = true;
    enableFishIntegration = true;
	  pinentryPackage = pkgs.pinentry-curses;
    defaultCacheTtl = 60;
    extraConfig =
      ''
      allow-emacs-pinentry
      allow-loopback-pinentry
      '';
    verbose = true;
  };
}
