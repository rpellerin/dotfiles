# dotfiles

Here are all my favorite dotfiles, taken from my Xubuntu 14.04.

## How do I use your files?
In a terminal, write the following:

1. `git clone https://github.com/rpellerin/dotfiles.git dotfiles`
2. `./dotfiles/scripts/fresh_install_script.sh`
3. Answer no to everything, except to "Do you wish to use the dotfiles from this git repo?"

I also added some other handy scripts in /scripts/.

## What to do after a fresh install of Xubuntu?

1. Install Chromium as a web browser. I wish I could use Mozilla Firefox however it's far behind Chromium, regarding performance.

2.

	```bash
	sudo apt-add-repository ppa:git-core/ppa

	sudo apt-get update
	sudo apt-get upgrade

	sudo apt-get install aptitude git ntp tmux imagemagick optipng texlive-full openjdk-8-jdk inotify-tools arandr gcolor2 vlc gksu gigolo gedit i3lock p7zip-full build-essential lib32stdc++6 gimp curl ffmpeg vim python3 zsh libreoffice libreoffice-l10n-fr libreoffice-help-fr hyphen-fr
	# lib32stdc++6 is for developing for Android on a 64-bit OS

	curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
	sudo apt-get install nodejs

	sudo apt-get install -f # To fix problems

	zsh # Configure it first by running it once
	chsh -s /bin/zsh # Need rebooting to take effect
	```

3. Check *Additional Drivers* in *Settings* to make sure all devices are being used.

4. Set up the xfce panel (top bar): show the battery indicator, set the date, time and timezone, sync the time with the Internet. Add network, RAM and CPU monitor.

5. Go through all the settings, in the *Settings Manager*. More importantly, set the keyboard shortcuts.

6. Set up **Thunderbird**.