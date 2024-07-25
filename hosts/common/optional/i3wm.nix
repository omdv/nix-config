{ pkgs, ... }: {
  services.xserver = {
    enable = true;

    displayManager.lightdm = {
      enable = true;
      greeters.mini = {
        enable = true;
        user = "om";
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-input-width = 24
          password-alignment = center
          show-sys-info = true
          [greeter-theme]
          background-image = ""
          background-color = "#121318"
          border-width = 1px
          border-color = "#38393f"
          password-border-color = "#38393f"
          password-border-width = 1px
          text-color = "#b8c3ff"
          password-color = "#ffb4ab"
          font-size = 12px
        '';
      };
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };

  environment.systemPackages = [
    pkgs.lightdm-mini-greeter
  ];
}
