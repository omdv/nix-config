COLOR_FOREGROUND_UNREAD="$1"

COUNT=$(find ~/Mail/*/Inbox/new -type f | wc -l)

if [ "$COUNT" == "0" ]; then
    echo "NO MAIL"
else
    echo "%{F$COLOR_FOREGROUND_UNREAD}MAIL $COUNT%{F-}"
fi
