#!/bin/sh

# Take a screenshot
# sudo apt install scrot
#scrot /tmp/screen_locked.png

# Blur it
# sudo apt install imagemagick
#mogrify -blur 0x8 /tmp/screen_locked.png

# Log in /var/log/syslog
logger Screen locked with i3lock

# Turn the screen off
(sleep 2 && xset dpms force off)&

# Lock screen
#/usr/bin/i3lock -i /tmp/screen_locked.png -n -t
i3lock -i /home/romain/Pictures/pause.png -n -t
# -n for no fork otherwise several instances could be launched by xss-lock
