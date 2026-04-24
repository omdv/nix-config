{pkgs, ...}: {
  imports = [
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
  ];

  home.packages = [
    pkgs.beancount
    pkgs.unstable.obsidian
    pkgs.sc-im
  ];
}
