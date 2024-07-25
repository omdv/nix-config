{ pkgs, ... }: {
  environment.systemPackages= with pkgs; [
    gnupg
    pinentry-curses
  ];
}
