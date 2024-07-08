{pkgs, ...}: {
  imports = [
    ./firefox.nix
    ./fonts.nix
    ./qutebrowser.nix
  ];

  # Scaling in GNOME
  dconf.settings."org/gnome/desktop/interface".text-scaling-factor = 1.28;
}
