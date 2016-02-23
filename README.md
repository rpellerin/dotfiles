# What to do after a fresh install of Xubuntu?

1. Install Chromium as a web browser. I wish I could use Mozilla Firefox however it's far behind Chromium, regarding performance.

2. Install many things:

	```bash
	sudo apt-add-repository ppa:git-core/ppa

	sudo apt-get update
	sudo apt-get upgrade

	sudo apt-get install aptitude \
        git \
        ntp \
        tmux \
        imagemagick \
        optipng \
        texlive-full \
        openjdk-8-jdk \
        inotify-tools \
        arandr \
        gcolor2 \
        vlc \
        gksu \
        gigolo \
        gedit \
        i3lock \
        p7zip-full \
        build-essential \
        lib32stdc++6 \
        gimp \
        curl \
        ffmpeg \
        vim \
        python3 \
        zsh \
        libreoffice \
        libreoffice-l10n-fr \
        libreoffice-help-fr \
        hyphen-fr
	# lib32stdc++6 is for developing for Android on a 64-bit OS

    # NodeJS
	curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
	sudo apt-get install nodejs # And read https://docs.npmjs.com/getting-started/fixing-npm-permissions

	sudo apt-get install -f # To fix problems

    # ZSH + Prezto
    zsh
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    chsh -s /bin/zsh # Might need rebooting to take effect

    # Install the firewall
    sudo cp -i scripts/firewall.sh /etc/init.d/
    sudo chmod 700 /etc/init.d/firewall.sh
    sudo chown root:root /etc/init.d/firewall.sh
    sudo update-rc.d firewall.sh defaults
	```

3. Check *Additional Drivers* in *Settings* to make sure all devices are being used.

4. Set up the xfce panel (top bar): show the battery indicator, set the date, time and timezone, sync the time with the Internet. Add network, RAM and CPU monitor.

5. Go through all the settings, in the *Settings Manager*. More importantly, set the keyboard shortcuts.

6. Set up **Thunderbird**. Most of the time, you can import the directory ~/.thunderbird (except the directory *Crash Reports*, inside, maybe) from another computer.

7. Install the [ownCloud client](https://software.opensuse.org/download/package?project=isv:ownCloud:desktop&package=owncloud-client).

8. You shoud install f.lux and launch it at startup (Menu>Settings>Session and startup): http://doc.ubuntu-fr.org/f.lux#installation_manuelle

## Optional stuff

### TeamViewer

    ```bash
    wget http://download.teamviewer.com/download/teamviewer_linux.deb -O /tmp/teamviewer.deb
    sudo dpkg -i /tmp/teamviewer.deb
    sudo apt-get install -f
    rm /tmp/teamviewer.deb -f
    ```

### Haskell & Pandoc

    ```bash
    sudo aptitude install haskell-platform
    cabal update
    cabal install pandoc
    cabal install pandoc-citeproc
    ```

### Optional Debian/Ubuntu packages

Installable with `npm install -g <package>`

- `exiftool` for EXIF data
- `jhead` for EXIF data
- `filezilla`
- `atom`
- `zenity` a simple interactive dialog
- `icoutils` to create Microsoft Windows(R) icon and cursor files
- `zathura` a PDF viewer
- `wireshark`
- `htop`
- `synaptic` see http://askubuntu.com/questions/76/whats-the-difference-between-package-managers
- `gtk-recordmydesktop`
- `pdf-presenter-console`
- `openvpn`
- `network-manager-openvpn`
- `network-manager-vpnc`
- `codeblocks`

### Optional npm packages

- `cloc` Count Lines of Code

### Optional Python packages

Installable with `pip install <package>`

- `eg` useful examples of common commands