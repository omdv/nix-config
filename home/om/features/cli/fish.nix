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
      # To check
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

      ec = "cd /home/om/Documents/nix-config && code .";
      snrs = "cd /home/om/Documents/nix-config && sudo nixos-rebuild --flake . switch";
      hms = "cd /home/om/Documents/nix-config && home-manager --flake . switch ";

    };
    functions = {
      # Disable greeting
      fish_greeting = "";
    };

    interactiveShellInit = ''
      # XDG configs
      set -gx XDG_CONFIG_HOME $HOME/.config
      set -gx XDG_DATA_HOME $HOME/.local/share
      set -gx XDG_STATE_HOME $HOME/.local/state
      set -gx XDG_CACHE_HOME $HOME/.cache

      # xdg folder cleanup
      set -gx ASDF_DATA_DIR $XDG_DATA_HOME/asdf
      set -gx CALCHISTFILE $XDG_CACHE_HOME/calc_history
      set -gx CARGO_HOME $XDG_DATA_HOME/cargo
      set -gx DOCKER_CONFIG $XDG_CONFIG_HOME/docker
      set -gx GOPATH $XDG_DATA_HOME/go
      set -gx HISTFILE $XDG_STATE_HOME/bash/history
      set -gx ELECTRUMDIR $XDG_DATA_HOME/electrum
      set -gx IPYTHONDIR $XDG_CONFIG_HOME/ipython
      set -gx JUPYTER_CONFIG_DIR $XDG_CONFIG_HOME/jupyter
      set -gx KERAS_HOME $XDG_STATE_HOME/keras
      set -gx LESSHISTFILE $XDG_CACHE_HOME/less/history
      set -gx NVM_DIR $XDG_DATA_HOME/nvm
      set -gx PASSWORD_STORE_DIR $XDG_DATA_HOME/pass
      set -gx PSQL_HISTORY $XDG_DATA_HOME/psql_history
      set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
      set -gx SQLITE_HISTORY $XDG_CACHE_HOME/sqlite_history
      set -gx LEDGER_FILE $HOME/Documents/ledger/hledger.journal
      set -gx OCI_CLI_RC_FILE $XDG_CONFIG_HOME/oci
      set -gx ELECTRUMDIR $XDG_DATA_HOME/electrum
      set -gx ZDOTDIR $XDG_CONFIG_HOME/zsh
      set -gx LEIN_HOME $XDG_DATA_HOME/lein

      # nnn
      set -gx NNN_PLUG "f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview"

      # asdf
      source "$HOME/.nix-profile/share/asdf-vm/asdf.fish"

      set -gx fzf_fd_opts --hidden --no-ignore --exclude=.git
      fzf_configure_bindings --git_status=\cg --variables=\cv --directory=\cf --git_log=\cl --processes=\ct
    '';
  };
}
