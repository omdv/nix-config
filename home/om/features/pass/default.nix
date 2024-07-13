{
  pkgs,
  ...
}: {
  # # better pass
  # home.packages = with pkgs; [
  #   gopass
  # ];

  programs.password-store = {
    enable = true;
    # settings = {
    #   PASSWORD_STORE_DIR = "$XDG_DATA_HOME/pass";
    # };
    package = pkgs.pass.withExtensions (p: [p.pass-otp]);
  };

  # services.pass-secret-service = {
  #   enable = true;
  #   storePath = "$XDG_DATA_HOME/pass";
  #   extraArgs = ["-e${config.programs.password-store.package}/bin/pass"];
  # };
}
