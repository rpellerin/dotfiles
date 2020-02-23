#!/bin/bash -x

# TO INSTALL:
# sudo bash -c "echo 'SUBSYSTEM=="drm", ACTION=="change", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/romain/.Xauthority", RUN+="/home/romain/git/dotfiles/scripts/hdmi_sound_toggle.sh"' > /lib/udev/rules.d/hdmi_sound.rules

# Sources
# - http://jeffhoogland.blogspot.com/2014/02/howto-switch-to-hdmi-audio-out.html
# - https://askubuntu.com/questions/458194/switching-to-hdmi-audio-when-hdmi-is-plugged-into-a-laptop-14-04

# Needed for pactl and xrandr to work when called by udev
# https://unix.stackexchange.com/questions/14854/xrandr-command-not-executed-within-shell-command-called-from-udev-rule
#export DISPLAY=:0

# Needed for xrandr to work when called by udev
#export XAUTHORITY=/home/romain/.Xauthority

intern=eDP-1
extern=HDMI-1

touch /tmp/debug_xrandr
echo "$DISPLAY" >> /tmp/debug_xrandr
echo "$XAUTHORITY" >> /tmp/debug_xrandr

# To force audio on HDMI when plugged, run this once:
# xrandr --output HDMI-1 --set audio on
# xrandr --output eDP-1 --set audio auto

sleep 1

# Check whether HDMI-1 and eDP-1 are set to "audio: on" with xrandr --prop
#if pactl list cards | grep -q 'Active Profile: output:hdmi-stereo';then
if xrandr | grep -q "$extern connected"; then
    /usr/bin/xrandr --output "$intern" --off --output "$extern" --set audio on --mode 1920x1080 >> /tmp/debug_xrandr 2>&1
    sleep 1
    # Line below not needed because of --set audio on (= forced)
    pactl set-card-profile 0 output:hdmi-stereo
else
    sleep 1
    #/usr/bin/xrandr --output "$extern" --off --output "$intern" --auto >> /tmp/debug_xrandr 2>&1
    # Line below not needed because of --set audio on (= forced)
    pactl set-card-profile 0 output:analog-stereo+input:analog-stereo
fi
