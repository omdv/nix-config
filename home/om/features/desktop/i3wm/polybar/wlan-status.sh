INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')

COLOR_GE80="$1"
COLOR_GE60="$2"
COLOR_GE40="$3"
COLOR_LOWR="$4"

# As per #36 -- It is transparent: e.g. if the machine has no battery or wireless
# connection (think desktop), the corresponding block should not be displayed.
[[ ! -d /sys/class/net/${INTERFACE}/wireless ]] && exit

# If the wifi interface exists but no connection is active, "down" shall be displayed.
if [[ "$(cat /sys/class/net/"$INTERFACE"/operstate)" = 'down' ]]; then
    echo "%{F$COLOR_LOWR}󰖪 {F-}"
    exit
fi

#------------------------------------------------------------------------

# SSID=$(iw ${INTERFACE} info | grep -Po '(?<=ssid ).*')
# SSID=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d\: -f2)
QUALITY=$(iw dev "${INTERFACE}" link | grep 'dBm$' | grep -Eoe '-[0-9]{2}' | awk '{print  ($1 > -50 ? 100 :($1 < -100 ? 0 : ($1+100)*2))}')

#------------------------------------------------------------------------

# color
if [[ $QUALITY -ge 75 ]]; then
    COLOR=$COLOR_GE80
elif [[ $QUALITY -ge 50 ]]; then
    COLOR=$COLOR_GE60
elif [[ $QUALITY -ge 30 ]]; then
    COLOR=$COLOR_GE40
else
    COLOR=$COLOR_LOWR
fi

echo "%{F$COLOR}󰖩 $QUALITY% %{F-}"
