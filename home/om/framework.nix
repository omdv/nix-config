{ inputs, config, ... }: {
  imports = [
    ./global

    ./features/desktop/common
    ./features/desktop/i3wm

    ./features/cli
    ./features/nixvim
    ./features/productivity
    ./features/pass

    ./features/optional/mpv.nix
    ./features/optional/pyradio.nix
    ./features/optional/quickemu.nix
    ./features/optional/zathura.nix
    ./features/optional/zotero.nix

    ./features/gaming/wesnoth.nix
    ./features/gaming/cdda.nix

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

  # sops-nix
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets.fastmail_password = { sopsFile = ./secrets.yaml; };
    secrets.gmail_password = { sopsFile = ./secrets.yaml; };
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  i3scaling = {
    dpi = 144; #96 is 1.0 scale
    gtkFontSize = 12;
    cursorSize = 36;
  };
}
