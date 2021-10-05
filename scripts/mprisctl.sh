#!/bin/sh

# Alternatively, you can use
# - sudo apt install playerctl
# - playerctl --list-all
# - playerctl play-pause

case "$1" in
	play-pause )
		func=PlayPause
		;;
	next )
		func=Next
		;;
	previous )
		func=Previous
		;;
	play )
		func=Play
		;;
	pause )
		func=Pause
		;;
	stop )
		func=Stop
		;;
	* )
		exit 3
esac

# get first mpris interface
bus=$(dbus-send --session           \
  --dest=org.freedesktop.DBus \
  --type=method_call          \
  --print-reply=literal       \
  /org/freedesktop/DBus       \
  org.freedesktop.DBus.ListNames |
  tr ' ' '\n' |
  grep 'org.mpris.MediaPlayer2' |
  head -n 1)

dbus-send --type=method_call --dest=$bus /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.$func
