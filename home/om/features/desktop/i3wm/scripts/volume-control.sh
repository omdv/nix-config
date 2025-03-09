# You can call this script like this:
# $ ./volume-control.sh up
# $ ./volume-control.sh down

# Script inspired by these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_volume {
  # Extract the float value and multiply by 100 to get percentage
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

function send_notification {
  local step=$1
  local step_percent
  step_percent=$(printf "%.0f" "$(echo "$step * 100" | bc)")
  icon=""
  volume=$(get_volume)
  # Use step_percent for the bar calculation
  bar=$(seq -s "─" 0 $((volume / step_percent / 10)) | sed 's/[0-9]//g')
  # Send the notification
  echo "$icon $volume% $bar"
  dunstify -r 4444 -u normal "$icon  $volume%  $bar"
}

case $1 in
  up)
    # increase the volume by x% amount
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$2"+
    send_notification "$2"  # Pass $2 as an argument
    ;;
  down)
    # decrease the volume by x% amount
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$2"-
    send_notification "$2"  # Pass $2 as an argument
    ;;
  mute)
    # mute the volume
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    dunstify -r 4444 -u normal "Volume toggle"
    ;;
esac
