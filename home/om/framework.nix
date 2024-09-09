{
  inputs,
  config,
  ...
}: {
  imports = [
    ./global

    ./features/desktop/common
    ./features/desktop/i3wm

    ./features/cli
    ./features/nixvim
    ./features/productivity
    ./features/pass

    ./features/optional/quickemu.nix
    ./features/optional/mpv.nix
    ./features/optional/zathura.nix
    ./features/optional/zotero.nix
    ./features/optional/zed.nix

    ./backup/framework.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  # colorscheme
  colorscheme.source = "#2B3975";
  colorscheme.type = "tonal-spot";

  monitors = [
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      workspace = "1";
      primary = true;
      scale = 1.0;
    }
  ];

  i3scaling = {
    dpi = 144; #96 is 1.0 scale
    gtkFontSize = 12;
    cursorSize = 36;
  };

  # sops-nix
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets.email_fastmail_address = {
      sopsFile = ./secrets.yaml;
    };
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

}
