# Copyright (C) 2014 Alexander Keller <github@nycroth.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#------------------------------------------------------------------------
INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')
#------------------------------------------------------------------------

COLOR_GE80="$1"
COLOR_GE60="$2"
COLOR_GE40="$3"
COLOR_LOWR="$4"

# COLOR_GE80=${COLOR_GE80:-#00FF00}
# COLOR_GE60=${COLOR_GE60:-#FFF600}
# COLOR_GE40=${COLOR_GE40:-#FFAE00}
# COLOR_LOWR=${COLOR_LOWR:-#FF0000}
# COLOR_DOWN=${COLOR_LOWR}

# As per #36 -- It is transparent: e.g. if the machine has no battery or wireless
# connection (think desktop), the corresponding block should not be displayed.
[[ ! -d /sys/class/net/${INTERFACE}/wireless ]] && exit

# If the wifi interface exists but no connection is active, "down" shall be displayed.
if [[ "$(cat /sys/class/net/"$INTERFACE"/operstate)" = 'down' ]]; then
    echo "%{F$COLOR_LOWR}down%{F-}"
    exit
fi

#------------------------------------------------------------------------

# SSID=$(iw ${INTERFACE} info | grep -Po '(?<=ssid ).*')
# SSID=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d\: -f2)
QUALITY=$(iw dev "${INTERFACE}" link | grep 'dBm$' | grep -Eoe '-[0-9]{2}' | awk '{print  ($1 > -50 ? 100 :($1 < -100 ? 0 : ($1+100)*2))}')

#------------------------------------------------------------------------

# color
if [[ $QUALITY -ge 80 ]]; then
    COLOR=$COLOR_GE80
elif [[ $QUALITY -ge 60 ]]; then
    COLOR=$COLOR_GE60
elif [[ $QUALITY -ge 40 ]]; then
    COLOR=$COLOR_GE40
else
    COLOR=$COLOR_LOWR
fi

echo "%{F$COLOR}WLAN $QUALITY% %{F-}"
