#!/bin/sh

# Alternatively, you can use
# - sudo apt install playerctl
# - playerctl --list-all
# - playerctl play-pause

# File to store the "last known active" player
STATE_FILE="/tmp/last_mpris_player"

case "$1" in
    play-pause) func=PlayPause ;;
    next)       func=Next ;;
    previous)   func=Previous ;;
    play)       func=Play ;;
    pause)      func=Pause ;;
    stop)       func=Stop ;;
    *)          exit 3 ;;
esac

# 1. Get all players
raw_players=$(dbus-send --session --dest=org.freedesktop.DBus \
  --type=method_call --print-reply=literal /org/freedesktop/DBus \
  org.freedesktop.DBus.ListNames | tr ' ' '\n' | grep 'org.mpris.MediaPlayer2')

[ -z "$raw_players" ] && exit 0

active_player=""
first_player=""
remembered_player=$(cat "$STATE_FILE" 2>/dev/null)

# 2. Loop to find the best candidate
while read -r player; do
    [ -z "$player" ] && continue
    [ -z "$first_player" ] && first_player="$player"

    status=$(dbus-send --print-reply --dest="$player" \
        /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
        string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' 2>/dev/null \
        | awk -F'"' '/variant/ {print $2}')

    if [ "$status" = "Playing" ]; then
        active_player="$player"
        # We found the one actually making noise, save it!
        echo "$player" > "$STATE_FILE"
        break
    fi
done <<EOF
$raw_players
EOF

# 3. Decision Logic
if [ -n "$active_player" ]; then
    target="$active_player"
elif [ -n "$remembered_player" ] && echo "$raw_players" | grep -q "$remembered_player"; then
    # If nothing is playing, but our "remembered" player still exists in the list
    target="$remembered_player"
else
    # Total fallback
    target="$first_player"
fi

# 4. Fire the command and update memory if we are "Playing" (Resuming)
if [ -n "$target" ]; then
    dbus-send --type=method_call --dest="$target" \
        /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."$func"

    # If we just told a player to Play or PlayPause, let's remember it for next time
    echo "$target" > "$STATE_FILE"
fi
