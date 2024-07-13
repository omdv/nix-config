{
  pkgs,
  ...
}: {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "";
    };
    package = pkgs.pass.withExtensions (p: [p.pass-otp]);
  };
}
