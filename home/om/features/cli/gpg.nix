{
  pkgs,
  lib,
  ...
}: {
  programs.gpg = {
    enable = true;
    settings = {};
  };

  # enabling gpg-agent services
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = lib.mkDefault pkgs.pinentry-curses;
    defaultCacheTtl = 1800;
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
    verbose = true;
  };
}
