#!/usr/bin/env bash
# List listening localhost TCP ports and open the selected one in qutebrowser.
# Sources: ss (host sockets) + podman ps (container-published ports).

FONT="$1"

# Ports that serve no HTTP UI — skip them
BLOCKLIST="22 5355"

# Overlay for ports not in /etc/services
declare -A OVERLAY
OVERLAY[3000]="dev-server"
OVERLAY[4200]="angular"
OVERLAY[5173]="vite"
OVERLAY[8000]="dev-server"
OVERLAY[8080]="dev-server"
OVERLAY[9000]="dev-server"
OVERLAY[11434]="ollama"

label_for_port() {
  local port="$1"
  local proc="$2"

  # process name from ss (own processes)
  if [ -n "$proc" ]; then
    echo "$proc"
    return
  fi

  # overlay for well-known non-standard ports
  if [ -n "${OVERLAY[$port]}" ]; then
    echo "${OVERLAY[$port]}"
    return
  fi

  # /etc/services lookup
  local svc
  svc=$(awk -v p="$port" '$2 ~ "^"p"/tcp" { print $1; exit }' /etc/services 2>/dev/null)
  [ -n "$svc" ] && echo "$svc" && return

  echo ""
}

gather_ss_ports() {
  ss -tlnp | tail -n +2 | while IFS= read -r line; do
    addr=$(echo "$line" | awk '{ print $4 }')
    proc=$(echo "$line" | awk '{ print $6 }')
    port="${addr##*:}"
    host="${addr%:*}"

    case "$host" in
      0.0.0.0|127.0.0.1|"[::]"|"[::1]") ;;
      *) continue ;;
    esac

    # shellcheck disable=SC2076  # literal match intentional
    [[ " $BLOCKLIST " =~ " $port " ]] && continue

    # extract process name if ss can see it (own processes)
    name=""
    [[ "$proc" =~ \(\(\"([^\"]+)\" ]] && name="${BASH_REMATCH[1]}"

    label=$(label_for_port "$port" "$name")

    if [ -n "$label" ]; then
      echo "$port — $label"
    else
      echo "$port"
    fi
  done
}

# Podman publishes ports via kernel NAT (rootful) or pasta/slirp (rootless).
# Rootful ports never appear in ss on the host; read them from podman directly.
gather_podman_ports() {
  command -v podman >/dev/null 2>&1 || return 0
  podman ps --format '{{.Names}}\t{{.Ports}}' 2>/dev/null | while IFS=$'\t' read -r cname ports; do
    [ -z "$ports" ] && continue
    while IFS= read -r mapping; do
      mapping="${mapping// /}"
      [ -z "$mapping" ] && continue
      # "0.0.0.0:8080->80/tcp" -> host portion -> port
      host_part="${mapping%%->*}"
      host_port="${host_part##*:}"
      [[ "$host_port" =~ ^[0-9]+$ ]] || continue
      # shellcheck disable=SC2076  # literal match intentional
      [[ " $BLOCKLIST " =~ " $host_port " ]] && continue
      echo "$host_port — $cname"
    done < <(tr ',' '\n' <<< "$ports")
  done
}

entries=$({ gather_ss_ports; gather_podman_ports; } | sort -un)

if [ -z "$entries" ]; then
  rofi -e "No listening ports found on localhost."
  exit 0
fi

selected=$(echo "$entries" | rofi -dmenu -p "localhost" -mesg "Select a port to open in qutebrowser" -font "$FONT" -i)
[ -z "$selected" ] && exit 0

port=$(echo "$selected" | awk '{ print $1 }')
qutebrowser "http://localhost:$port"
