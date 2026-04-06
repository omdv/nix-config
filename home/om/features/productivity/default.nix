{pkgs, ...}: {
  imports = [
    ./khard.nix
    ./mail.nix
    ./neomutt.nix
  ];

  home.packages = [
    pkgs.beancount # ledger alternative
    pkgs.sc-im
  ];
}
