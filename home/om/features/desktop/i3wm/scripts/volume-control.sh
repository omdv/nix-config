#!/usr/bin/env bash
# You can call this script like this:
# $ ./volume-control.sh up
# $ ./volume-control.sh down
# $ ./volume-control.sh mute

# Script inspired by these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_volume {
  wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

function volume_icon {
  local vol=$1
  if   [ "$vol" -eq 0 ];   then echo "audio-volume-muted"
  elif [ "$vol" -le 33 ];  then echo "audio-volume-low"
  elif [ "$vol" -le 66 ];  then echo "audio-volume-medium"
  else                          echo "audio-volume-high"
  fi
}

function send_notification {
  local volume icon
  volume=$(get_volume)
  icon=$(volume_icon "$volume")
  dunstify -r 4444 -u normal \
    -i "$icon" \
    -h int:value:"$volume" \
    -h string:x-dunst-stack-tag:osd \
    "Volume  $volume%"
}

case $1 in
  up)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$2"+
    send_notification
    ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$2"-
    send_notification
    ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
      dunstify -r 4444 -u normal \
        -i "audio-volume-muted" \
        -h string:x-dunst-stack-tag:osd \
        "Volume  Muted"
    else
      send_notification
    fi
    ;;
esac
