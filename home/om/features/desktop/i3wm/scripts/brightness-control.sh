#!/usr/bin/env bash
# You can call this script like this:
# $ ./brightnessControl.sh up
# $ ./brightnessControl.sh down

# Script inspired by these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_brightness {
  light -G | cut -d '.' -f 1
}

function send_notification {
  local brightness
  brightness=$(get_brightness)
  dunstify -r 5555 -u normal \
    -i "display-brightness" \
    -h int:value:"$brightness" \
    -h string:x-dunst-stack-tag:osd \
    "Brightness  $brightness%"
}

case $1 in
  up)
    light -A "$2"
    send_notification
    ;;
  down)
    light -U "$2"
    send_notification
    ;;
esac
