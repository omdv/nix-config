{pkgs, ...}: {
  imports = [
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
  ];

  home.packages = [
    pkgs.beancount
    pkgs.obsidian
    pkgs.sc-im
  ];
}
