SINK_NAME="$1"
SINK_ID=$(pactl list short sinks | awk -v name="$SINK_NAME" '$2 == name {print $1}')

# Function to get the current volume of the known sink
get_volume() {
    pactl get-sink-volume "$SINK_NAME" | grep -oP '\d+%' | head -n 1
}

# Initial volume display
CURRENT_VOLUME=$(get_volume)
echo "$CURRENT_VOLUME"

# Subscribe to PulseAudio events and filter for sink changes
pactl subscribe | grep --line-buffered "Event 'change' on sink" | while read -r event; do
    # Check if the event is for our known sink
    if echo "$event" | grep -q "$SINK_ID"; then
        # Get the current volume of the known sink
        VOLUME=$(get_volume)
        echo "$VOLUME"
    fi
done
