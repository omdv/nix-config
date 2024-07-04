{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;

  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;

  hasRipgrep = hasPackage "ripgrep";
  hasExa = hasPackage "eza";
  hasHtop = hasPackage "htop";
  hasFd = hasPackage "fd";
  hasDocker = hasPackage "docker";
  hasSpecialisationCli = hasPackage "specialisation";
  hasNeovim = config.programs.neovim.enable;
  hasEmacs = config.programs.emacs.enable;
  hasNeomutt = config.programs.neomutt.enable;
  hasShellColor = config.programs.shellcolor.enable;
  hasKitty = config.programs.kitty.enable;
  shellcolor = "${pkgs.shellcolord}/bin/shellcolor";

in {
  programs.fish = {
    enable = true;

    shellAbbrs = rec {
      # To discover
      s = mkIf hasSpecialisationCli "specialisation";
      cik = mkIf hasKitty "clone-in-kitty --type os-window";
      jqless = "jq -C | less -r";

      # Better tools
      find = mkIf hasFd "fd";
      ls = mkIf hasExa "eza -al";
      top = mkIf hasHtop "htop";
      vim = mkIf hasNeovim "nvim";
      mutt = mkIf hasNeomutt "neomutt";

      # Docker
      dc = mkIf hasDocker "docker-compose";
      dps = mkIf hasDocker "docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'";

    };
    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";

      snrs = "cd /home/om/Documents/nix-config && sudo nixos-rebuild --flake . switch";
      hms = "cd /home/om/Documents/nix-config && home-manager --flake . switch ";

    };
    functions = {
      # Disable greeting
      fish_greeting = "";
    };

    interactiveShellInit = ''
      set -gx NNN_PLUG "f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview"

      set -gx fzf_fd_opts --hidden --no-ignore --exclude=.git
      fzf_configure_bindings --git_status=\cg --variables=\cv --directory=\cf --git_log=\cl --processes=\ct
    '';
  };
}
