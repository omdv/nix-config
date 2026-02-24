{ pkgs, config, ... }:
let
  colors = config.colorscheme.palette;
in
{
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

      # Auto-rename windows to current directory
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}'

      # Status bar
      set -g status-style 'bg=#${colors.base03} fg=#${colors.base0E}'
      set -g status-left-length 40
      set -g status-right-length 20
      set -g status-left '#{b:pane_current_path} '
      set -g status-right '#{?client_prefix,PREFIX,}'
      set -g status-justify centre

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
    # tp: rofi script mode for tmux projects
    (pkgs.writeShellScriptBin "tp" ''
      PROJECTS_DIR="$HOME/projects"
      NIXOS_DIR="$HOME/nix-config"
      ACCOUNTING_DIR="$HOME/accounting"
      HOMELAB_DIR="$HOME/homelab"

      if [[ -z "$1" ]]; then
      {
        echo "$NIXOS_DIR"
        echo "$ACCOUNTING_DIR"
        echo "$HOMELAB_DIR"
        ${pkgs.fd}/bin/fd . "$PROJECTS_DIR" --type d --max-depth 1 | sort -u
      } | sort -u
      else
        # Argument provided: open the selected project
        selected="$1"
        selected_name=$(basename "$selected" | tr . _)

        if ! ${pkgs.tmux}/bin/tmux -L main has-session -t="$selected_name" 2> /dev/null; then
          ${pkgs.tmux}/bin/tmux -L main new-session -ds "$selected_name" -c "$selected"
        fi

        ${pkgs.util-linux}/bin/setsid -f ${pkgs.kitty}/bin/kitty -e ${pkgs.tmux}/bin/tmux -L main attach-session -t "$selected_name" >/dev/null 2>&1
      fi
    '')
  ];
}
