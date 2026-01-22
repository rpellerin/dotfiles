#!/bin/bash

# ==============================================================================
# 1. DYNAMICALLY DETECT AVAILABLE SINKS
# ==============================================================================
# We grab the full details of all sinks once to parse their status.
FULL_INFO=$(pactl list sinks)
# We grab the list of all Short IDs to iterate through.
ALL_IDS=$(pactl list sinks short | awk '{print $1}')

VALID_SINK_IDS=()
VALID_SINK_NAMES=()

for ID in $ALL_IDS; do
    # 1. Extract the text block for this specific Sink ID
    # We use sed to grab text from "Sink #ID" up to the next "Sink #"
    SINK_BLOCK=$(echo "$FULL_INFO" | sed -n "/^Sink #$ID$/,/^Sink #/p")

    # 2. Find the "Active Port" for this sink
    ACTIVE_PORT=$(echo "$SINK_BLOCK" | grep "Active Port:" | cut -d: -f2 | xargs)

    # 3. Check availability of that specific port
    IS_AVAILABLE=true

    if [ -n "$ACTIVE_PORT" ] && [ "$ACTIVE_PORT" != "n/a" ]; then
        # Find the specific line in the "Ports:" section for the Active Port.
        # It usually looks like: "hdmi-output-0: HDMI (..., not available)"
        PORT_STATUS_LINE=$(echo "$SINK_BLOCK" | grep -F "$ACTIVE_PORT:")

        # Check if the line contains negative availability keywords
        if echo "$PORT_STATUS_LINE" | grep -qE "not available|unplugged|availability: no"; then
            IS_AVAILABLE=false
        fi
    fi

    # 4. If available, add to our valid list
    if [ "$IS_AVAILABLE" = true ]; then
        VALID_SINK_IDS+=("$ID")

        # Extract a human-readable description (fallback to Name if missing)
        DESC=$(echo "$SINK_BLOCK" | grep "Description:" | cut -d: -f2 | xargs)
        if [ -z "$DESC" ]; then
             DESC=$(echo "$SINK_BLOCK" | grep "Name:" | cut -d: -f2 | xargs)
        fi
        VALID_SINK_NAMES+=("$DESC")
    fi
done

# Check if we have enough devices to cycle
COUNT=${#VALID_SINK_IDS[@]}
if [ "$COUNT" -lt 2 ]; then
    notify-send "Audio Error" "Found $COUNT available devices. Need at least 2 to toggle."
    exit 1
fi


# ==============================================================================
# 2. DETERMINE NEXT SINK
# ==============================================================================
CURRENT_SINK_NAME=$(pactl get-default-sink)
# Map the current name to an ID (so we can compare with our VALID_SINK_IDS list)
CURRENT_SINK_ID=$(pactl list sinks short | grep -F "$CURRENT_SINK_NAME" | awk '{print $1}' | head -n 1)

NEXT_ID=""
NEXT_NAME=""
FOUND_CURRENT=false

# Loop through our VALID list to find the next one
for ((i=0; i<COUNT; i++)); do
    ID="${VALID_SINK_IDS[$i]}"

    if [ "$FOUND_CURRENT" = true ]; then
        NEXT_ID="$ID"
        NEXT_NAME="${VALID_SINK_NAMES[$i]}"
        break
    fi

    if [ "$ID" -eq "$CURRENT_SINK_ID" ] 2>/dev/null; then
        FOUND_CURRENT=true
    fi
done

# Wrap Around: If we reached the end or didn't find current, go to the first valid device
if [ -z "$NEXT_ID" ]; then
    NEXT_ID="${VALID_SINK_IDS[0]}"
    NEXT_NAME="${VALID_SINK_NAMES[0]}"
fi

# Stuck Breaker: If logic fails and chooses the same device, force the second one
if [ "$NEXT_ID" == "$CURRENT_SINK_ID" ]; then
    NEXT_ID="${VALID_SINK_IDS[1]}"
    NEXT_NAME="${VALID_SINK_NAMES[1]}"
fi


# ==============================================================================
# 3. APPLY CHANGES
# ==============================================================================
# A. Set Default Sink for new apps
pactl set-default-sink "$NEXT_ID"

# B. Move currently playing streams (The "Fix" for sound continuing on old device)
pactl list short sink-inputs | while read -r stream; do
    STREAM_ID=$(echo "$stream" | awk '{print $1}')
    pactl move-sink-input "$STREAM_ID" "$NEXT_ID" 2>/dev/null
done

# C. Notify
notify-send -t 2000 "Audio Switched" "$NEXT_NAME"
echo "Switched to: $NEXT_NAME (ID: $NEXT_ID)"
