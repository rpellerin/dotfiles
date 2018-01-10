#!/bin/sh

# I could have used xautolock but it triggers the screensaver after a given time
# regardless of full-screen apps or videos.
# A solution could have been to detect such apps with
# https://github.com/iye/lightsOn/blob/master/lightsOn.sh
# but damn what a pain!

# Set the screensaver to fire after 120 seconds of inactivity, and then every 120seconds another program is run (further below, xset dpms)
(sleep 10 && xset s 120 120) &
# The sleep part is required otherwise our setting is overwritten by some other program at startup


# Lock the screen using i3lock when screensaver is fired or when lid is closed
xss-lock -n /home/romain/git/dotfiles/scripts/lock-screen.sh -- xset dpms force off
