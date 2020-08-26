#!/bin/sh

# I could have used xautolock but it triggers the screensaver after a given time
# regardless of full-screen apps or videos.
# A solution could have been to detect such apps with
# https://github.com/iye/lightsOn/blob/master/lightsOn.sh
# but damn what a pain!

# Set the screensaver to fire after 120 seconds of inactivity (length, first argument), and then every 120 seconds another program is run (period, second argument)
(sleep 10 && xset s 120 120) &
# The sleep part is required otherwise our setting is overwritten by some other program at startup

# For some reason, since Xubuntu 20.04, this program is started automatically
(sleep 10 && pidof xfce4-screensaver && kill `pidof xfce4-screensaver`) &

# Lock the screen using i3lock when screensaver is fired or when lid is closed
xss-lock -n /home/romain/git/dotfiles/scripts/lock-screen.sh -- sh -c "sleep 3 && /home/romain/git/dotfiles/scripts/lock-screen.sh"
