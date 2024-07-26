{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    settings = {};
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    defaultCacheTtl = 1800;
    extraConfig =
      ''
      allow-emacs-pinentry
      allow-loopback-pinentry
      '';
    verbose = true;
  };
}
