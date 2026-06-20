COLOR_FOREGROUND_NORMAL="$1"
COLOR_BACKGROUND_NORMAL="$2"
COLOR_FOREGROUND_WARN="$3"
COLOR_BACKGROUND_WARN="$4"
COLOR_FOREGROUND_ERROR="$5"
COLOR_BACKGROUND_ERROR="$6"
CPU_WARN="$7"
CPU_ERROR="$8"
MEM_WARN="$9"
MEM_ERROR="${10}"
TEMP_WARN="${11}"
TEMP_ERROR="${12}"
THERMAL_ZONE="${13}"

STAT_PATH="${POLYBAR_SYSTEM_STAT_PATH:-/proc/stat}"
MEMINFO_PATH="${POLYBAR_SYSTEM_MEMINFO_PATH:-/proc/meminfo}"
THERMAL_PATH="${POLYBAR_SYSTEM_THERMAL_PATH:-/sys/class/thermal/thermal_zone${THERMAL_ZONE}/temp}"

read_cpu_sample() {
    awk '/^cpu / {
        idle = $5 + $6;
        total = 0;
        for (i = 2; i <= NF; i++) {
            total += $i;
        }
        print idle, total;
        exit;
    }' "$STAT_PATH"
}

read_cpu_percent() {
    if [ -n "${POLYBAR_SYSTEM_CPU_PERCENT:-}" ]; then
        printf '%s\n' "$POLYBAR_SYSTEM_CPU_PERCENT"
        return
    fi

    [ -r "$STAT_PATH" ] || return

    local first second idle1 total1 idle2 total2 delta_idle delta_total busy
    first=$(read_cpu_sample)
    [ -n "$first" ] || return
    sleep 0.2
    second=$(read_cpu_sample)
    [ -n "$second" ] || return

    read -r idle1 total1 <<EOF
$first
EOF
    read -r idle2 total2 <<EOF
$second
EOF

    delta_idle=$((idle2 - idle1))
    delta_total=$((total2 - total1))
    [ "$delta_total" -gt 0 ] || return

    busy=$((delta_total - delta_idle))
    printf '%s\n' $(((busy * 100 + delta_total / 2) / delta_total))
}

read_mem_percent() {
    if [ -n "${POLYBAR_SYSTEM_MEM_PERCENT:-}" ]; then
        printf '%s\n' "$POLYBAR_SYSTEM_MEM_PERCENT"
        return
    fi

    [ -r "$MEMINFO_PATH" ] || return

    awk '
        /^MemTotal:/ { total = $2 }
        /^MemAvailable:/ { available = $2 }
        END {
            if (total > 0 && available >= 0) {
                used = total - available;
                printf "%d\n", int((used * 100 / total) + 0.5);
            }
        }
    ' "$MEMINFO_PATH"
}

read_temp_celsius() {
    if [ -n "${POLYBAR_SYSTEM_TEMP_C:-}" ]; then
        printf '%s\n' "$POLYBAR_SYSTEM_TEMP_C"
        return
    fi

    [ -r "$THERMAL_PATH" ] || return

    awk '{ printf "%d\n", int(($1 / 1000) + 0.5) }' "$THERMAL_PATH"
}

metric_severity() {
    local value="$1"
    local warn="$2"
    local error="$3"

    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        printf '0\n'
    elif [ "$value" -ge "$error" ]; then
        printf '2\n'
    elif [ "$value" -ge "$warn" ]; then
        printf '1\n'
    else
        printf '0\n'
    fi
}

max_severity() {
    local max=0
    local severity
    for severity in "$@"; do
        if [ "$severity" -gt "$max" ]; then
            max="$severity"
        fi
    done
    printf '%s\n' "$max"
}

format_field() {
    local value="$1"
    local width="$2"
    printf "%${width}s" "$value"
}

cpu_percent=$(read_cpu_percent)
mem_percent=$(read_mem_percent)
temp_celsius=$(read_temp_celsius)

cpu_severity=$(metric_severity "$cpu_percent" "$CPU_WARN" "$CPU_ERROR")
mem_severity=$(metric_severity "$mem_percent" "$MEM_WARN" "$MEM_ERROR")
temp_severity=$(metric_severity "$temp_celsius" "$TEMP_WARN" "$TEMP_ERROR")
block_severity=$(max_severity "$cpu_severity" "$mem_severity" "$temp_severity")

case "$block_severity" in
    2)
        foreground="$COLOR_FOREGROUND_ERROR"
        background="$COLOR_BACKGROUND_ERROR"
        ;;
    1)
        foreground="$COLOR_FOREGROUND_WARN"
        background="$COLOR_BACKGROUND_WARN"
        ;;
    *)
        foreground="$COLOR_FOREGROUND_NORMAL"
        background="$COLOR_BACKGROUND_NORMAL"
        ;;
esac

cpu_display=$(format_field "${cpu_percent:---}" 3)
mem_display=$(format_field "${mem_percent:---}" 3)
temp_display=$(format_field "${temp_celsius:---}" 3)

printf '%%{B%s}%%{F%s} %%{T3}%%{T-} %s%%  %%{T3}%%{T-} %s%%  %%{T3}%%{T-} %s°C %%{F-}%%{B-}\n' \
    "$background" \
    "$foreground" \
    "$cpu_display" \
    "$mem_display" \
    "$temp_display"
