#!/bin/bash -x

# TO INSTALL:
# sudo su
# echo 'KERNEL=="card1", SUBSYSTEM=="drm", ACTION=="change", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/romain/.Xauthority", RUN+="/home/romain/git/dotfiles/scripts/hdmi_sound_toggle.sh"' > /etc/udev/rules.d/99-hdmi_sound.rules
# exit
# You might need to swap `card1` with `card0`. Check what card you have:
# ls /dev/dri/
# or
# ls /run/udev/data/ | grep card

# Now:
# sudo udevadm control --reload-rules # Reload rules to take ours into account
# sudo udevadm trigger # Tells udev to re-process existing devices and generate events for them
# As a result, check that `/tmp/debug_xrandr`  exists
# cat /tmp/debug_xrandr
# sudo systemctl restart udev # Not sure this is needed
# systemctl daemon-reload # Not sure this is needed
# Debug with `udevadm monitor --environment`

# Sources
# - http://jeffhoogland.blogspot.com/2014/02/howto-switch-to-hdmi-audio-out.html
# - https://askubuntu.com/questions/458194/switching-to-hdmi-audio-when-hdmi-is-plugged-into-a-laptop-14-04

# $DISPLAY and $XAUTHORITY are needed for pactl and xrandr to work when called by udev
# https://unix.stackexchange.com/questions/14854/xrandr-command-not-executed-within-shell-command-called-from-udev-rule
# They are provided inside `/etc/udev/rules.d/99-hdmi_sound.rules`.

BUILTIN_MONITOR=eDP-1
HDMI_EXTERN=HDMI-1
HDMI_EXTERN_THROUGH_HUB=DP-1
HDMI_CARD_PROFILE="output:hdmi-stereo"

# Get UID of user running pipewire (uses the first if more than one)
PUID=`ps -C pipewire -o ruid= | head -n 1 | awk '{print $1}'`
CARD_PROFILE_ID=`sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl list cards short | head -n 1 | cut -f1`

touch /tmp/debug_xrandr
date >> /tmp/debug_xrandr
echo "DISPLAY:$DISPLAY;XAUTHORITY:$XAUTHORITY;PUID:$PUID;CARD_PROFILE_ID:$CARD_PROFILE_ID" >> /tmp/debug_xrandr

change_sound="true"
connected_output="none"

sleep 1

if xrandr | grep -q -E "^($HDMI_EXTERN_THROUGH_HUB|$HDMI_EXTERN|DisplayPort-0) connected"; then
    sleep 2 # Needed, for the next line to work (instead of being always !false, hence true)
    if ! (sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl list cards | grep "$HDMI_CARD_PROFILE" | grep 'available: yes'); then
       change_sound="false"
    fi

    if xrandr | grep -q -E "^$HDMI_EXTERN_THROUGH_HUB connected"; then
        echo "HDMI connected through hub" >> /tmp/debug_xrandr
        connected_output=$HDMI_EXTERN_THROUGH_HUB
    elif xrandr | grep -q -E "^DisplayPort-0 connected"; then
        echo "HDMI connected through ???. Aborting and exiting." >> /tmp/debug_xrandr
        exit 0
    else
        echo "HDMI connected directly" >> /tmp/debug_xrandr
        connected_output=$HDMI_EXTERN
    fi

    if [ $change_sound == "true" ]; then
        echo "Changing sound" >> /tmp/debug_xrandr
        sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl set-card-profile $CARD_PROFILE_ID $HDMI_CARD_PROFILE >> /tmp/debug_xrandr 2>&1
        sleep 3 # For some reason it sometimes does not work, maybe too fast? Better to retry
        sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl set-card-profile $CARD_PROFILE_ID $HDMI_CARD_PROFILE >> /tmp/debug_xrandr 2>&1
        echo "Success?:$?" >> /tmp/debug_xrandr
    else
        echo "NOT changing sound" >> /tmp/debug_xrandr
        sleep 2
    fi

    echo "xfce4-display-settings:$(pidof xfce4-display-settings)" >> /tmp/debug_xrandr
    pidof xfce4-display-settings && kill $(pidof xfce4-display-settings)

    sleep 1
    xrandr --output $BUILTIN_MONITOR --off --output $connected_output --primary
else
    if [ $change_sound == "true" ]; then
        echo "HDMI NOT CONNECTED, reverting back to laptop speakers+internal mic" >> /tmp/debug_xrandr
        sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl set-card-profile $CARD_PROFILE_ID output:analog-stereo+input:analog-stereo >> /tmp/debug_xrandr 2>&1
    fi
fi

echo "change_sound=$change_sound;connected_output=$connected_output" >> /tmp/debug_xrandr
