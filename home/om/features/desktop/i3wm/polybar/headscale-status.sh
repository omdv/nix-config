# Check if we have both color arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <ok_color> <error_color>"
    exit 1
fi

OK_COLOR="$1"
ERROR_COLOR="$2"

# Check if tailscale is installed
if ! command -v tailscale &> /dev/null; then
    echo "%{F$ERROR_COLOR}󰖂 ERR %{F-}"
    exit 0
fi

# Get tailscale status
status_output=$(tailscale status --json)

# Check if tailscale is running/connected
if [ "$(echo "$status_output" | jq '.Self.Online')" = false ]; then
    echo "%{F$ERROR_COLOR}󰖂 DOWN %{F-}"
    exit 0
fi

# Count online peers (excluding this machine)
online_peers=$(echo "$status_output" | jq '[.Peer[].Online | select(. == true)] | length')
echo "%{F$OK_COLOR}󰖂 $online_peers%{F-}"
