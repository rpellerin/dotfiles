#!/bin/sh

# Take a screenshot
scrot /tmp/screen_locked.png

# Blur it
mogrify -blur 0x8 /tmp/screen_locked.png

# Lock screen
/usr/bin/i3lock -i /tmp/screen_locked.png -n -t

# Log in /var/log/syslog
logger Screen locked with i3lock

# Turn the screen off after a delay
sleep 60; pgrep i3lock && xset dpms force off
