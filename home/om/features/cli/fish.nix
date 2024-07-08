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
  hasKubecolor = hasPackage "kubecolor";
  hasGopass = hasPackage "gopass";

  hasBat = config.programs.bat.enable;
  hasNnn = config.programs.nnn.enable;
  hasNeovim = config.programs.neovim.enable || config.programs.nixvim.enable;
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
      n = mkIf hasNnn "nnn";
      pass = mkIf hasGopass "gopass";

    };
    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";

      # Better tools
      kubectl = mkIf hasKubecolor "kubecolor";
      k = mkIf hasKubecolor "kubecolor";
      cat = mkIf hasBat "bat";

      # Shortcuts
      ec = "cd /home/om/Documents/nix-config && code .";
      ff = "source ~/.config/fish/config.fish";
      dc = mkIf hasDocker "docker-compose";
      dps = mkIf hasDocker "docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'";
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
      set -gx LEDGER_FILE $HOME/Documents/ledger/hledger.journal
      set -gx LEIN_HOME $XDG_DATA_HOME/lein
      set -gx NVM_DIR $XDG_DATA_HOME/nvm
      set -gx OCI_CLI_RC_FILE $XDG_CONFIG_HOME/oci
      # set -gx PASSWORD_STORE_DIR $XDG_DATA_HOME/pass
      set -gx PSQL_HISTORY $XDG_DATA_HOME/psql_history
      set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
      set -gx SQLITE_HISTORY $XDG_CACHE_HOME/sqlite_history
      set -gx ZDOTDIR $XDG_CONFIG_HOME/zsh

      # kubeconfig
      set -gx KUBECONFIG $HOME/.kube/config:$HOME/Documents/devops/homelab-server/provision/kubeconfig

      # nnn
      set -Ux NNN_PLUG "o:fzopen;p:preview-tui;d:diffs;t:tree;f:finder;s:stats"
      set -gx NNN_FIFO "/tmp/nnn.fifo"

      # asdf
      source "$HOME/.nix-profile/share/asdf-vm/asdf.fish"

      # direnv
      direnv hook fish | source

      # fzf general settings
      set -gx FZF_DEFAULT_OPTS --inline-info --height 100%

      # fzf.fish settings
      set -gx fzf_fd_opts --hidden --no-ignore --exclude=.git --max-depth 5
      set -gx fzf_preview_dir_cmd eza --all --color=always
      set -gx fzf_preview_file_cmd bat -n
      set -gx fzf_diff_highlighter diff-so-fancy
      fzf_configure_bindings --git_status=\cg --variables=\cv --directory=\cf --git_log=\cl --processes=\ct
    '';
  };
}
