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
  hasNnn = config.programs.nnn.enable;
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

      # Better tools
      find = mkIf hasFd "fd";
      ls = mkIf hasExa "eza -al";
      top = mkIf hasHtop "htop";
      vim = mkIf hasNeovim "nvim";
      mutt = mkIf hasNeomutt "neomutt";
      pass = mkIf hasGopass "gopass";
      ya = mkIf hasYazi "yazi";

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
      kubectl = mkIf hasKubecolor "kubecolor";
      k = mkIf hasKubecolor "kubecolor";
      cat = mkIf hasBat "bat";

      # Shortcuts
      ec = "cd /home/om/Documents/nix-config && code .";
      ff = "source ~/.config/fish/config.fish";
    };
    functions = {
      # Disable greeting
      fish_greeting = "";
      # n wrapper with cd quit
      n = mkIf hasNnn ''
        # Block nesting of nnn in subshells
        if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
            echo "nnn is already running"
            return
        end

        # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
        # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
        # see. To cd on quit only on ^G, remove the "-x" from both lines below,
        # without changing the paths.
        if test -n "$XDG_CONFIG_HOME"
            set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
        else
            set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
        end

        # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
        # stty start undef
        # stty stop undef
        # stty lwrap undef
        # stty lnext undef

        # The command function allows one to alias this function to `nnn` without
        # making an infinitely recursive alias
        command nnn $argv

        if test -e $NNN_TMPFILE
            source $NNN_TMPFILE
            rm -- $NNN_TMPFILE
        end
      '';
      # sgpt integration
      _sgpt_commandline = ''
        # Get the current command line content
        set -l _sgpt_prompt (commandline)

        # Only proceed if there is a prompt
        if test -z "$_sgpt_prompt"
            return
        end

        # Append an hourglass to the current command
        commandline -a "⌛"
        commandline -f end-of-line  # needed to display the icon

        # Get the output of the sgpt command
        set -l _sgpt_output (echo "$_sgpt_prompt" | sgpt --shell --no-interaction)

        if test $status -eq 0
            # Replace the command line with the output from sgpt
            commandline -r -- (string trim "$_sgpt_output")
            commandline -a "  # $_sgpt_prompt"
        else
            # If the sgpt command failed, remove the hourglass
            commandline -f backward-delete-char
            commandline -a "  # ERROR: sgpt command failed"
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

      # nnn
      set -Ux NNN_PLUG "o:fzopen;p:preview-tui;d:diffs;t:tree;f:finder;s:stats"
      set -gx NNN_FIFO "/tmp/nnn.fifo"

      # # asdf
      # source "$HOME/.nix-profile/share/asdf-vm/asdf.fish"

      # direnv
      direnv hook fish | source

      # fzf.fish and settings
      fzf_configure_bindings --git_status=\cg --variables=\cv --directory=\cf --git_log=\cl --processes=\ct
      set -gx fzf_fd_opts --hidden --no-ignore --exclude=.git --max-depth 5
      set -gx fzf_preview_dir_cmd eza --all --color=always
      set -gx fzf_diff_highlighter diff-so-fancy

      # sgpt integration
      bind \cs _sgpt_commandline
    '';
  };
}
