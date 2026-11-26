{pkgs, ...}: {
  home.packages = [pkgs.easyeffects];

  systemd.user.services.easyeffects = {
    Unit = {
      Description = "EasyEffects background audio processing";
      Wants = [
        "pipewire.service"
        "wireplumber.service"
      ];
      After = [
        "graphical-session.target"
        "pipewire.service"
        "wireplumber.service"
      ];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --service-mode";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}
