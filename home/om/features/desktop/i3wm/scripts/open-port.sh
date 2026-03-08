#!/usr/bin/env bash
# List listening localhost TCP ports and open the selected one in qutebrowser.

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

entries=$(ss -tlnp | tail -n +2 | while IFS= read -r line; do
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
done | sort -un)

if [ -z "$entries" ]; then
  rofi -e "No listening ports found on localhost."
  exit 0
fi

selected=$(echo "$entries" | rofi -dmenu -p "localhost" -mesg "Select a port to open in qutebrowser" -font "$FONT" -i)
[ -z "$selected" ] && exit 0

port=$(echo "$selected" | awk '{ print $1 }')
qutebrowser "http://localhost:$port"
