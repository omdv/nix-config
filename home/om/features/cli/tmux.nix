{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    prefix = "C-a";
    aggressiveResize = true;
    clock24 = true;
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = ''
      # Kitty Color & Clipboard Support
      set -g default-terminal "tmux-256color"
      set -as terminal-overrides ',xterm-kitty:RGB'
      set -as terminal-overrides ",xterm-kitty:Ms=\\E]52;c;%p2%s\\7"

      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1

      # Bind 'Prefix + f' to switch projects inside tmux
      bind-key -r f run-shell "tmux neww t"
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          # Restore shell history and pane contents
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session' # If you use nvim
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          # Auto-restore on tmux start
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15' # Save every 15 mins
        '';
      }
    ];
  };

  home.packages = [
    (pkgs.writeShellScriptBin "t" ''
      # Shows directories that have a flake.nix or devenv.nix file
      selected=$( ${pkgs.fd}/bin/fd '^(flake|devenv)\.nix$' ~/projects --type f --exec echo '{//}' \
        | sort -u \
        | ${pkgs.fzf}/bin/fzf )

      if [[ -z $selected ]]; then exit 0; fi

      selected_name=$(basename "$selected" | tr . _)

      if ! tmux has-session -t="$selected_name" 2> /dev/null; then
          tmux new-session -ds "$selected_name" -c "$selected"
      fi

      if [[ -z $TMUX ]]; then
          tmux attach-session -t "$selected_name"
      else
          tmux switch-client -t "$selected_name"
      fi
    '')
  ];
}
