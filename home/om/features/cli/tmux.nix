{
  pkgs,
  config,
  ...
}: let
  colors = config.colorscheme.palette;
in {
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

      # Enable extended keys support
      set -as terminal-features ',*:extkeys'
      set -g extended-keys on
      set -g extended-keys-format csi-u
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

    # tssh: rofi script mode for tailscale hosts -> tmux ssh session
    (pkgs.writeShellScriptBin "tssh" ''
      TAILSCALE_BIN="${pkgs.tailscale}/bin/tailscale"
      JQ_BIN="${pkgs.jq}/bin/jq"

      resolve_port() {
        host="$1"
        short_host="''${host%%.*}"

        # 1) ssh config resolution (best source)
        port="$(ssh -G "$host" 2>/dev/null | awk '/^port /{print $2; exit}')"
        if [[ -n "$port" && "$port" != "22" ]]; then
          echo "$port"
          return 0
        fi

        # 2) try short host alias in ssh config
        if [[ -n "$short_host" && "$short_host" != "$host" ]]; then
          port="$(ssh -G "$short_host" 2>/dev/null | awk '/^port /{print $2; exit}')"
          if [[ -n "$port" && "$port" != "22" ]]; then
            echo "$port"
            return 0
          fi
        fi

        # 3) known_hosts fallback for entries like [host]:2222
        if [[ -f "$HOME/.ssh/known_hosts" ]]; then
          port="$(awk -v host="$host" '
            {
              split($1, entries, ",")
              for (i in entries) {
                if (entries[i] ~ "^\\[" host "\\]:[0-9]+$") {
                  p = entries[i]
                  sub("^\\[" host "\\]:", "", p)
                  print p
                  exit
                }
              }
            }
          ' "$HOME/.ssh/known_hosts" 2>/dev/null)"

          if [[ -z "$port" && -n "$short_host" && "$short_host" != "$host" ]]; then
            port="$(awk -v host="$short_host" '
              {
                split($1, entries, ",")
                for (i in entries) {
                  if (entries[i] ~ "^\\[" host "\\]:[0-9]+$") {
                    p = entries[i]
                    sub("^\\[" host "\\]:", "", p)
                    print p
                    exit
                  }
                }
              }
            ' "$HOME/.ssh/known_hosts" 2>/dev/null)"
          fi
        fi

        # default
        echo "''${port:-22}"
      }

      if [[ -z "$1" ]]; then
        if ! command -v "$TAILSCALE_BIN" >/dev/null 2>&1; then
          echo "tailscale-not-installed"
          exit 0
        fi

        "$TAILSCALE_BIN" status --json 2>/dev/null | "$JQ_BIN" -r '
          (.Peer // {})
          | to_entries
          | map(.value)
          | map(select((.Online // false) == true))
          | map({
              host: ((.DNSName // .HostName // .Name // "") | sub("\\.$"; "")),
              ip: (.TailscaleIPs[0] // "")
            })
          | map(select(.host != ""))
          | sort_by(.host)
          | .[]
          | "\(.host)\t\(.ip)"
        ' | while IFS=$'\t' read -r host ip; do
          port="$(resolve_port "$host")"
          printf "%-32s | %-15s | :%s\n" "$host" "$ip" "$port"
        done
      else
        selected="$1"
        host="''${selected%% | *}"
        host="$(echo "$host" | sed 's/[[:space:]]*$//')"

        if [[ -z "$host" || "$host" == "tailscale-not-installed" ]]; then
          exit 0
        fi

        port="$(resolve_port "$host")"
        session_name="ssh_$(echo "$host" | tr '.:@' '___' | tr -cd '[:alnum:]_-' )"

        if ! ${pkgs.tmux}/bin/tmux -L main has-session -t="$session_name" 2>/dev/null; then
          ${pkgs.tmux}/bin/tmux -L main new-session -ds "$session_name" "ssh -p $port $host"
        fi

        ${pkgs.util-linux}/bin/setsid -f ${pkgs.kitty}/bin/kitty -e ${pkgs.tmux}/bin/tmux -L main attach-session -t "$session_name" >/dev/null 2>&1
      fi
    '')
  ];
}
