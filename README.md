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
        vim-gtk \
        python3 \
        zsh \
        libreoffice \
        libreoffice-l10n-fr \
        libreoffice-help-fr \
        hyphen-fr
	# lib32stdc++6 is for developing for Android on a 64-bit OS
	# vim-gtk for clipboard support

    # NodeJS
	curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
	sudo apt-get install nodejs # And read https://docs.npmjs.com/getting-started/fixing-npm-permissions

	sudo apt-get install -f # To fix problems

    cd dotfiles # cd to this git repo
    REPO_DIR=`pwd`

    # ZSH + Prezto
    zsh
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    chsh -s /bin/zsh # Might need rebooting to take effect

    # Install the firewall
    sudo cp -i $REPO_DIR/scripts/firewall.sh /etc/init.d/
    sudo chmod 700 /etc/init.d/firewall.sh
    sudo chown root:root /etc/init.d/firewall.sh
    sudo update-rc.d firewall.sh defaults

    # Custom settings
    echo "source $REPO_DIR/.rc" >> $HOME/.zshrc
    echo "source $REPO_DIR/.aliases" >> $HOME/.zshrc
    ln -sf $REPO_DIR/.tmux.conf $HOME/
    cp -i "$REPO_DIR/Pictures/pause.png" $HOME/Pictures/pause.png
    ln -sf "$REPO_DIR/.gitconfig" $HOME/
    ln -sf $REPO_DIR/.curlrc $HOME/
    ln -sf $REPO_DIR/.vimrc $HOME/
    ln -s $REPO_DIR/.ycm_extra_conf.py $HOME/
    ln -s $REPO_DIR/.tern-project $HOME/
    diff $REPO_DIR/.zpreztorc $HOME/.zprezto/runcoms/zpreztorc

    # Set up Vim
    ## Vundle (Vim package manager)
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    ### Then go to https://github.com/VundleVim/Vundle.vim
    ## Install YouCompleteMe by reading https://github.com/Valloric/YouCompleteMe/blob/master/README.md#ubuntu-linux-x64 (no need to read the "Full Installation Guide" section)
    ## Finally, deactivate your firewall (just in case), launch Vim and run:
    :PluginInstall
	```

3. Check *Additional Drivers* in *Settings* to make sure all devices are being used.

4. Set up the xfce panel (top bar): show the battery indicator (if on a laptop), set the date, time and timezone, sync the time with the Internet. Add network, RAM and CPU monitor.

5. Go through all the settings, in the *Settings Manager*.

    - More importantly, set the keyboard shortcuts (*Tile window to the x*, *Show desktop*).
    - Also, change the DNS servers to those from FDN (http://blog.fdn.fr/?post/2014/12/07/Filtrer-The-Pirate-Bay-Ubu-roi-des-Internets).
    - Finally, in *Keyboard*, bind the command `i3lock -i /home/romain/Pictures/pause.png -n -t` with *Ctrl+Alt+Delete*.

6. Set up **Thunderbird**. Most of the time, you can import the directory *~/.thunderbird* (except the directory *Crash Reports*, inside, maybe) from another computer.

7. Install the [ownCloud client](https://software.opensuse.org/download/package?project=isv:ownCloud:desktop&package=owncloud-client).

8. You shoud install f.lux and launch it at startup (Menu>Settings>Session and startup): http://doc.ubuntu-fr.org/f.lux#installation_manuelle

9. On a laptop, you should install [https://github.com/tmux-plugins/tmux-battery](https://github.com/tmux-plugins/tmux-battery):

    ```bash
    git clone https://github.com/tmux-plugins/tmux-battery $HOME/.tmux-battery
    ```
    
    Also, make sure nothing happens when you close the lid (in both plugged mode or battery mode).


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

- `exiftool` for EXIF data
- `jhead` for EXIF data
- `filezilla`
- `atom (go to official website to download the .deb file)`
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

Installable with `npm install -g <package>`.

- `cloc` Count Lines of Code

### Optional Python packages

Installable with `pip install <package>`.

- `eg` useful examples of common commands
