COLOR_FOREGROUND_BAD="$1"

USER_FAILED=$(systemctl --user list-units --state=failed --no-legend 2>/dev/null | wc -l)
SYSTEM_FAILED=$(systemctl --system list-units --state=failed --no-legend 2>/dev/null | wc -l)

COUNT=$(( USER_FAILED + SYSTEM_FAILED ))

if [ "$COUNT" -gt 0 ]; then
    echo "%{F$COLOR_FOREGROUND_BAD} $COUNT failed%{F-}"
else
    echo ""
fi
