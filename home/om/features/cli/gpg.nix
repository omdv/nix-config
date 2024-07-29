{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    settings = {};
  };

  # enabling gpg-agent services
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentryPackage = pkgs.pinentry-rofi;
    defaultCacheTtl = 1800;
    extraConfig =
      ''
      allow-emacs-pinentry
      allow-loopback-pinentry
      '';
    verbose = true;
  };
}
