{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;

  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;

  hasExa = hasPackage "eza";
  hasHtop = hasPackage "htop";
  hasFd = hasPackage "fd";
  hasKubecolor = hasPackage "kubecolor";
  hasGopass = hasPackage "gopass";

  hasBat = config.programs.bat.enable;
  hasNeovim = config.programs.neovim.enable || config.programs.nixvim.enable;
  hasNeomutt = config.programs.neomutt.enable;
  hasKitty = config.programs.kitty.enable;
  hasYazi = config.programs.yazi.enable;
in {
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.3";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
    ];

    shellAbbrs = {
      # Clone-in-kitty
      cik = mkIf hasKitty "clone-in-kitty --type os-window";

      # Nix shortcuts
      snrs = "nh os switch .";
      hms = "nh home switch .";
      nixgc = "nix-collect-garbage -d";

      # Docker shortcuts
      docker = "podman";
      docker-compose = "podman-compose";
      dps = "docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'";
    };

    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";

      # Better tools
      ai = "aichat";
      cat = mkIf hasBat "bat";
      find = mkIf hasFd "fd";
      k = mkIf hasKubecolor "kubecolor";
      kubectl = mkIf hasKubecolor "kubecolor";
      ls = mkIf hasExa "eza -al";
      mutt = mkIf hasNeomutt "neomutt";
      pass = mkIf hasGopass "gopass";
      top = mkIf hasHtop "htop";
      vim = mkIf hasNeovim "nvim";
      ya = mkIf hasYazi "yazi";
    };
    functions = {
      # Disable greeting
      fish_greeting = "";
      nfit = ''
        set -l key $argv[1]
        set -l template

        switch "$key"
          case python py
            set template python
          case rust rs
            set template rust
          case nodejs node js
            set template nodejs
          case '*'
            echo "Usage: nfit [python|rust|nodejs]"
            return 1
        end

        nix flake init -t ~/nix-config#$template
        or return 1

        if test ! -f .envrc
          printf "use flake\n" > .envrc
        end
      '';
    };
    interactiveShellInit = ''
      # XDG configs
      set -gx XDG_CONFIG_HOME $HOME/.config
      set -gx XDG_DATA_HOME $HOME/.local/share
      set -gx XDG_STATE_HOME $HOME/.local/state
      set -gx XDG_CACHE_HOME $HOME/.cache

      # kitty TERM for ssh
      set -gx TERM xterm-256color

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
      set -gx PASSWORD_STORE_DIR $HOME/.password-store
      set -gx PSQL_HISTORY $XDG_DATA_HOME/psql_history
      set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
      set -gx SQLITE_HISTORY $XDG_CACHE_HOME/sqlite_history
      set -gx ZDOTDIR $XDG_CONFIG_HOME/zsh

      # kubeconfig
      set -gx KUBECONFIG $HOME/.kube/config:$HOME/Documents/devops/homelab-server/provision/kubeconfig

      # direnv
      direnv hook fish | source

      # fzf.fish and settings
      fzf_configure_bindings --git_status=\eg --variables=\cv --directory=\cf --git_log=\cl --processes=\ct
      set -gx fzf_fd_opts --hidden --no-ignore --exclude=.git --max-depth 5
      set -gx fzf_preview_dir_cmd eza --tree --level=2 --color=always
      set -gx fzf_diff_highlighter diff-so-fancy

      # sgpt integration
      bind \cs _sgpt_commandline
    '';
  };
}
