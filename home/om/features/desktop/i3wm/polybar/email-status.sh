COLOR_FOREGROUND="$1"

COUNT=$(find ~/Mail/*/Inbox/new -type f | wc -l)

if [ "$COUNT" == "0" ]; then
    echo ""
else
    echo "%{F$COLOR_FOREGROUND}󰇮 $COUNT%{F-}"
fi
