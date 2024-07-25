COLOR_FOREGROUND_GOOD="$1"
COLOR_FOREGROUND_BAD="$2"

COUNT=$(systemctl --user list-units -all | grep -c "failed" | tr -d \\n)

if [ "$COUNT" == "0" ]; then
    echo "%{F$COLOR_FOREGROUND_GOOD}SYS $COUNT%{F-}"
else
    echo "%{F$COLOR_FOREGROUND_BAD}SYS $COUNT%{F-}"
fi
