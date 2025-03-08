# You can call this script like this:
# $ ./brightnessControl.sh up
# $ ./brightnessControl.sh down

# Script inspired by these wonderful people:
# https://github.com/dastorm/volume-notification-dunst/blob/master/volume.sh
# https://gist.github.com/sebastiencs/5d7227f388d93374cebdf72e783fbd6a

function get_brightness {
  # convert to integer
  light -G | cut -d '.' -f 1
}

function send_notification {
  local step=$1
  icon=""
  brightness=$(get_brightness)
  # Divide by 10 to get a shorter bar (10 segments max instead of 100)
  bar=$(seq -s "─" 0 $((brightness / step / 10)) | sed 's/[0-9]//g')
  # Send the notification
  dunstify -r 5555 -u normal "$icon    $bar $brightness%"
}

case $1 in
  up)
    # increase the backlight by x% amount
    light -A "$2"
    send_notification "$2"  # Pass $2 as an argument
    ;;
  down)
    # decrease the backlight by x% amount
    light -U "$2"
    send_notification "$2"  # Pass $2 as an argument
    ;;
esac
