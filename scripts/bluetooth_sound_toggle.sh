#!/bin/bash -x

# TO INSTALL:
# sudo su
# echo 'SUBSYSTEM=="bluetooth", ACTION=="add", RUN+="/home/romain/git/dotfiles/scripts/bluetooth_sound_toggle.sh"' > /etc/udev/rules.d/98-bluetooth_sound.rules
# udevadm control --reload-rules
# systemctl restart udev
# Debug with `udevadm monitor`

PUID=`ps -C pulseaudio -o ruid= | awk '{print $1}'`

# date >> /tmp/debugg

sleep 5

NAME=$(sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl list sinks | grep -P '(?<=Name: )bluez_sink\..*\.a2dp_sink' -o);
if [ "$?" -eq 0 ]; then
    # echo "found it" >> /tmp/debugg
    sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl set-default-sink "$NAME"
fi
