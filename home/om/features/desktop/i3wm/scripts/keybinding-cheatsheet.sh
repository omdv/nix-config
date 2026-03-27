#!/usr/bin/env bash

# i3wm Keybinding Cheatsheet
# Generates a nice image and displays it with feh
# Args: $1=font, $2=bg_color, $3=fg_color, $4=accent_color, $5=header_color

TMPFILE="/tmp/i3-cheatsheet.png"

# Get screen resolution for sizing
SCREEN_WIDTH=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f1)
SCREEN_HEIGHT=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f2)

# 50% of screen size
WIDTH=$((SCREEN_WIDTH * 50 / 100))
HEIGHT=$((SCREEN_HEIGHT * 50 / 100))

# Calculate column positions
COL1=60
COL2=$((WIDTH / 2 + 20))

# Color scheme from colorscheme.palette
BG_COLOR="#${2}"
FG_COLOR="#${3}"
ACCENT_COLOR="#${4}"
HEADER_COLOR="#${5}"

# Create the cheatsheet image
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -font "DejaVu-Sans-Mono" \
    -gravity NorthWest \
    -fill "$HEADER_COLOR" -pointsize 32 -annotate +${COL1}+40 "i3wm Keybinding Cheatsheet" \
    -fill "$FG_COLOR" -pointsize 14 -annotate +${COL1}+90 "Mod = Super/Windows Key" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL1}+140 "APPLICATIONS" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +$((COL1+20))+170 "Mod + Return        Open terminal (kitty)" \
    -annotate +$((COL1+20))+195 "Mod + d             Application launcher (rofi)" \
    -annotate +$((COL1+20))+220 "Mod + l             Lock screen" \
    -annotate +$((COL1+20))+245 "Mod + o             Open localhost port" \
    -annotate +$((COL1+20))+270 "Mod + n             WiFi menu" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL1}+315 "WINDOWS & LAYOUT" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +$((COL1+20))+345 "Mod + f             Toggle fullscreen" \
    -annotate +$((COL1+20))+370 "Mod + Shift + q     Kill window" \
    -annotate +$((COL1+20))+395 "Mod + Shift + Space Toggle floating" \
    -annotate +$((COL1+20))+420 "Mod + r             Resize mode" \
    -annotate +$((COL1+20))+445 "Mod + w             Tabbed layout" \
    -annotate +$((COL1+20))+470 "Mod + s             Stacking layout" \
    -annotate +$((COL1+20))+495 "Mod + e             Split layout" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL1}+540 "FOCUS & MOVE" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +$((COL1+20))+570 "Mod + Arrow         Focus window" \
    -annotate +$((COL1+20))+595 "Mod + Shift + Arrow Move window" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL2}+140 "WORKSPACES" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +${COL2}+170 "Mod + 1-9           Switch to workspace" \
    -annotate +${COL2}+195 "Mod + Shift + 1-9   Move to workspace" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL2}+240 "SCREENSHOTS" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +${COL2}+270 "Mod + Print         Screenshot selection" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL2}+315 "MEDIA & SYSTEM" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +${COL2}+345 "Vol Up/Down         Volume control" \
    -annotate +${COL2}+370 "Mute                Toggle mute" \
    -annotate +${COL2}+395 "Bright Up/Down      Brightness control" \
    \
    -fill "$ACCENT_COLOR" -pointsize 18 -annotate +${COL2}+440 "i3 CONTROL" \
    -fill "$FG_COLOR" -pointsize 16 \
    -annotate +${COL2}+470 "Mod + F1            This cheatsheet" \
    -annotate +${COL2}+495 "Mod + Shift + c     Reload config" \
    -annotate +${COL2}+520 "Mod + Shift + r     Restart i3" \
    -annotate +${COL2}+545 "Mod + Shift + e     Exit i3" \
    \
    -fill "$FG_COLOR" -pointsize 14 -gravity South -annotate +0+30 "Press ESC or click to close" \
    "$TMPFILE"

# Display with feh - centered, borderless, and closes on click/ESC
feh --geometry ${WIDTH}x${HEIGHT} \
    --auto-zoom \
    --borderless \
    --title "i3 Keybinding Cheatsheet" \
    "$TMPFILE"

# Clean up
rm -f "$TMPFILE"
