{pkgs, ...}: {
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;
    enableFishIntegration = false;
    settings = {
      theme = "catppuccin-mocha";
      show_release_notes = false;
    };
  };

  home.packages = [
    # tp: rofi script mode for project sessions
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

        if ! ${pkgs.zellij}/bin/zellij list-sessions --short 2>/dev/null | ${pkgs.gnugrep}/bin/grep -Fxq "$selected_name"; then
          ${pkgs.zellij}/bin/zellij attach -b "$selected_name" options --default-cwd "$selected" >/dev/null 2>&1
        fi

        ${pkgs.util-linux}/bin/setsid -f ${pkgs.kitty}/bin/kitty -e ${pkgs.zellij}/bin/zellij attach "$selected_name" >/dev/null 2>&1
      fi
    '')

    # tssh: rofi script mode for tailscale hosts -> zellij ssh session
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

        if ! ${pkgs.zellij}/bin/zellij list-sessions --short 2>/dev/null | ${pkgs.gnugrep}/bin/grep -Fxq "$session_name"; then
          ${pkgs.zellij}/bin/zellij attach -b "$session_name" options --default-cwd "$HOME" >/dev/null 2>&1
          ${pkgs.zellij}/bin/zellij --session "$session_name" action write-chars "ssh -p $port $host"
          ${pkgs.zellij}/bin/zellij --session "$session_name" action write 13
        fi

        ${pkgs.util-linux}/bin/setsid -f ${pkgs.kitty}/bin/kitty -e ${pkgs.zellij}/bin/zellij attach "$session_name" >/dev/null 2>&1
      fi
    '')
  ];
}
