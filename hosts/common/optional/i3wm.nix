{ pkgs, ... }: {
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle";
    };

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
          show-input-cursor = true

          [greeter-theme]
          background-image = ""
          background-color = "#121318"
          border-width = 1px
          window-color = "#ffb4ab"
          border-color = "#38393f"
          layout-space = 5
          password-border-color = "#38393f"
          password-border-width = 1px
          password-background-color = "#1B1D1E"
          text-color = "#b8c3ff"
          password-color = "#F8F8F0"
          font-size = 12px

          sys-info-font = "Sans"
          sys-info-font-size = 0.8em
          sys-info-margin = -5px -5px -5px
          sys-info-color = "#b8c3ff"
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
