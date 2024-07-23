SINK_NAME="$1"
SINK_ID=$(pactl list short sinks | awk -v name="$SINK_NAME" '$2 == name {print $1}')

get_status() {
    local volume_info
    local volume
    local mute_status
    volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    volume=$(echo "$volume_info" | awk '{print $2}')
    mute_status=$(echo "$volume_info" | grep -q MUTED && echo "yes" || echo "no")
    echo "$volume $mute_status"
}


# Initial volume display
print_logic() {
    local status
    local volume
    local mute_status
    status=$(get_status)
    volume=$(echo "$status" | awk '{print $1 * 100}')
    mute_status=$(echo "$status" | awk '{print $2}')

    if [ "$mute_status" == "yes" ]; then
        echo "MUTED"
    else
        echo "$volume%"
    fi
}

main_loop() {
    # Subscribe to PulseAudio events and filter for sink changes
    pactl subscribe | grep --line-buffered "Event 'change' on sink" | while read -r event; do
        # Check if the event is for our known sink
        if echo "$event" | grep -q "$SINK_ID"; then
            # Get the current volume of the known sink
            print_logic
        fi
    done
}

print_logic
main_loop
