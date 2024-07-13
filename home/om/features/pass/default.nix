{
  pkgs,
  config,
  ...
}: {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "";
    };
    package = pkgs.pass.withExtensions (p: [p.pass-otp]);
  };

  services.pass-secret-service = {
    enable = true;
    extraArgs = ["-e${config.programs.password-store.package}/bin/pass"];
  };
}
