{
  pkgs,
  config,
  ...
}: {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
    package = pkgs.pass.withExtensions (p: [p.pass-otp]);
  };
  home.packages = with pkgs; [
    gopass
  ];
}
