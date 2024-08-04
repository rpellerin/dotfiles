#!/bin/bash -x

if [ $(pactl list sinks short | wc -l) -lt 2 ]; then
    echo "Less than 2 sinks"
    exit 1
fi

# Get UID of user running pulseaudio (uses the first if more than one)
PUID=`ps -C pulseaudio -o ruid= | awk '{print $1}'`
SINK_1_ID=`pactl list sinks short | head -n 1 | cut -f1`
SINK_1_NAME=`pactl list sinks short | head -n 1 | awk '{print $2}'`
SINK_2_ID=`pactl list sinks short | tail -n 1 | cut -f1`
SINK_2_NAME=`pactl list sinks short | tail -n 1 | awk '{print $2}'`

if pactl info | grep -q "$SINK_1_NAME"; then
    pactl set-default-sink $SINK_2_ID
    NAME=$SINK_2_NAME
else
    pactl set-default-sink $SINK_1_ID
    NAME=$SINK_1_NAME
fi

notify-send -t 4000 "Toggled sink to $NAME"

