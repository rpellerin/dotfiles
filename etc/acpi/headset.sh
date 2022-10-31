#!/bin/bash -x

# TO INSTALL:
# Copy this file and etc/acpi/events/headset to the root of the filesystem (same directories)
# `sudo systemctl restart acpid.service`
# Debug with `journalctl -f`

case "$3" in
	plug)
		PUID=`ps -C pulseaudio -o ruid= | awk '{print $1}'`

		logger "Headset plugged in (event: $1,$2,$3) - see /etc/acpi/events/headset"
		# Logs visible in `journalctl -f`

		sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl set-source-port alsa_input.pci-0000_00_1f.3.analog-stereo analog-input-headset-mic
		sudo -u "#$PUID" XDG_RUNTIME_DIR=/run/user/$PUID pactl set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo
		;;
esac


