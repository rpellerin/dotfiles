# What to do after a fresh install of Xubuntu?

![How to secure your laptop](https://raw.githubusercontent.com/rpellerin/dotfiles/master/Pictures/secure-laptop.png)

## 1. BIOS

Upgrade the bios by downloading the latest image from [Dell.com](http://www.dell.com/support/home/us/en/19/product-support/product/latitude-14-7480-laptop/drivers?os=biosa). (Alternatively, you can try to download the image from [this website](https://fwupd.org/lvfs/devicelist) and install it through "Software" (simply open the file).) Then:

```bash
sudo cp Downloads/Latitude_7x80_1.4.6.exe /boot/efi # Not mv because of permissions
rm Downloads/Latitude_7x80_1.4.6.exe
```

Reboot, hit F12 to initiate the update. Once done, reboot and press F2 to enter BIOS setup. Set a password for the BIOS and the hard drive. Don't forget to remove the file from `/boot/efi`.

## 2. Google Chrome

Download Chrome .deb file and then:

```bash
sudo dpgk -i google-chrome-stable.deb
sudo apt install -f # To fix dependencies problems
sudo dpgk -i google-chrome-stable.deb
rm -f google-chrome-stable.deb
```

## 3. Visual Studio Code

[Download VS code .deb file](https://code.visualstudio.com/docs/setup/linux) and then:

```bash
sudo dpgk -i code_1.27_amd64.deb
sudo apt install -f # To fix dependencies problems
sudo dpgk -i code_1.27_amd64.deb
rm -f code_1.27_amd64.deb
```

## 4. Firefox
    
- In [about:config](about:config), do:
    - Disable the HTTP referer: set `network.http.sendRefererHeader` to `0`.
    - Set `security.tls.version.min` to `3` ([more info](https://support.mozilla.org/fr/questions/1103968))
    - Set `view_source.wrap_long_lines` to `true`.
    - Set `browser.tabs.warnOnClose` to `false`.
    - Set `browser.tabs.closeWindowWithLastTab` to `false`.
    - Set `network.prefetch-next` to `false`.
    - Set `network.dns.disablePrefetch` to `false`.
    - Set `datareporting.healthreport.uploadEnabled` to `false`.
    - Set `general.useragent.override` to `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/47.0.2526.73 Chrome/47.0.2526.73 Safari/537.36`
    - Set `privacy.resistFingerprinting` to `true` (this voids the effect of `general.useragent.override`).
    - Set `gfx.webrender.enabled` to `true`.
    - Set `geo.enabled` to `false`.
    - Set `browser.safebrowsing.malware.enabled` to `false`.
    - Set `browser.safebrowsing.phishing.enabled` to `false`
    - Set `browser.send_pings` to `false`
    - Set `dom.battery.enabled` to `false`
    - Set `media.navigator.enabled` to `false`
    - Set `network.trr.mode` to `2` ([https://blog.nightly.mozilla.org/2018/06/01/improving-dns-privacy-in-firefox/](https://blog.nightly.mozilla.org/2018/06/01/improving-dns-privacy-in-firefox/https://blog.nightly.mozilla.org/2018/06/01/improving-dns-privacy-in-firefox/) + [DNS-over-HTTPS functionality in Firefox](https://gist.github.com/bagder/5e29101079e9ac78920ba2fc718aceec)).
    - Set `network.trr.uri` to `https://mozilla.cloudflare-dns.com/dns-query`.
- In [about:preferences#general](about:preferences#general), check `Restore previous session`.
- In [about:preferences#search](about:preferences#search), add the search bar in the toolbar
- In [about:preferences#privacy](about:preferences#privacy), uncheck everything under `Firefox Data Collection and Use`. Also, block cookies for the following domains:
    - https://s.ytimg.com
    - https://www.youtube.com
    - https://r5---sn-25glenes.googlevideo.com
    - https://i.ytimg.com

    Also, disable third-party cookies and enable `Tracking Protection` and `Do Not Track` at all times.
- Add these extensions:
    - [tabliss.io](https://tabliss.io/)
    - [React Developer Tools](https://github.com/facebook/react-devtools)
    - [Redux DevTools](https://github.com/zalmoxisus/redux-devtools-extension)

## 5. Git

```bash
sudo apt-add-repository ppa:git-core/ppa
sudo apt update
sudo apt install git git-extras
```

## 6. Essential packages

```bash
sudo apt update
sudo apt upgrade
sudo apt install gnupg2 \
    xclip \
    autojump \
    ctags \
    tree \
    ntp \
    imagemagick \
    optipng \
    inotify-tools \
    vlc \
    gksu \
    gigolo \
    i3lock \
    xss-lock \
    p7zip-full \
    build-essential \
    gimp \
    curl \
    ffmpeg \
    vim-gtk \
    python3 \
    zsh \
    libreoffice \
    libreoffice-l10n-fr \
    libreoffice-l10n-en-gb \
    libreoffice-help-en-gb \
    libreoffice-help-fr \
    libreoffice-pdfimport \
    hyphen-fr \
    hyphen-en-gb \
    hunspell-en-gb \
    unattended-upgrades \
    redshift-gtk \
    pass

# Pass is a password manager
# Rofi is an app launcher
# An alternative to autojump is z: https://github.com/rupa/z
# xss-lock is for auto locking session after 2 minutes of inactivity
# vim-gtk for clipboard support
# ctags is for vim tag jumping (see .vimrc)
# libreoffice-pdfimport is for PDF signing
# redshift-gtk is an alternative to xflux
# For automatic security updates, run `sudo dpkg-reconfigure unattended-upgrades`
```

## 7. Optional packages

```bash
sudo apt install texlive-full \
    texlive-bibtex-extra \
    biber \
    arandr \
    gcolor2 \
    mpd mpv \
    ranger \
    pass \
    rofi

# Install biber from apt first and try to compile a PDF document.
# If there is any compatibility issue, install it from http://biblatex-biber.sourceforge.net/ (sudo cp biber /usr/local/bin)
# See https://bugs.launchpad.net/ubuntu/+source/biber/+bug/1565842

# MPD is a music player for terminal, MPV is a video player compatible with Youtube and co.
# Ranger is a file explorer
```

## 8. Thunderbird

Download Thunderbird 60 `.deb` file. Then extract it and:

```bash
sudo mv thunderbird/ /opt
sudo ln -s /opt/thunderbird/thunderbird /usr/bin/
```

## 9. Tmux

```bash
sudo apt install libevent-dev libncurses-dev pkg-config automake autoconf
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make
sudo make install
```

## 10. Ranger

It adds image preview support:

```bash
mkdir -p ~/.config/ranger
echo 'set preview_images true' >> ~/.config/ranger/rc.conf
ranger --copy-config=scope
```

## 11. ZSH + Prezto

```bash
zsh
# Press the 'q' key
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh # Might need rebooting to take effect
```

## 12. NVM + NodeJS

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
# Make sure ~/.zshrc does not contain code added by nvm install script,
# since it is already present in dotfiles/.rc
nvm install node
# Or install Nodejs directly
# curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
# sudo apt install nodejs # And read https://docs.npmjs.com/getting-started/fixing-npm-permissions
```

## 13. Battery saver (https://doc.ubuntu-fr.org/tlp)

```bash
sudo apt install tlp
sudo systemctl enable tlp
sudo systemctl enable tlp-sleep
```

## 14. Firewall

```bash
cd dotfiles # cd to this git repo
sudo cp -i scripts/firewall.sh /etc/init.d/
sudo chmod 700 /etc/init.d/firewall.sh
sudo chown root:root /etc/init.d/firewall.sh
sudo update-rc.d firewall.sh defaults
```

## 14. Custom conf files

```bash
cd dotfiles # cd to this git repo
REPO_DIR=`pwd`

# Custom settings
ln -sf $REPO_DIR/.vimrc $HOME/
mkdir -p $HOME/.vim
for file in .vim/**/*.*; do
    ln -sf $REPO_DIR/`dirname $file` $HOME/.vim
done
echo "source $REPO_DIR/.rc" >> $HOME/.zshrc
echo "source $REPO_DIR/.aliases" >> $HOME/.zshrc
ln -sf $REPO_DIR/.tmux.conf $HOME/
cp -i "$REPO_DIR/Pictures/pause.png" $HOME/Pictures/pause.png
mkdir -p $HOME/.config/autostart
cp $REPO_DIR/.config/autostart/* "$HOME/.config/autostart"
cp "$REPO_DIR/.config/redshift.conf" $HOME/.config/
ln -sf "$REPO_DIR/.gitconfig" $HOME/
ln -sf "$REPO_DIR/.git-templates" $HOME/
ln -sf "$REPO_DIR/.gitignore_global" $HOME/
ln -sf $REPO_DIR/.curlrc $HOME/
ln -sf $REPO_DIR/.less $HOME/
ln -sf $REPO_DIR/.lesskey $HOME/
ln -s $REPO_DIR/.ycm_extra_conf.py $HOME/
ln -s $REPO_DIR/.tern-project $HOME/
ln -s $REPO_DIR/.eslintrc.js $HOME/
ln -s $REPO_DIR/.config/compton.conf $HOME/.config/

source "$REPO_DIR/.rc"
git diff $HOME/.zprezto/runcoms/zpreztorc $REPO_DIR/.zpreztorc
ln -s "$REPO_DIR/.zpreztorc" $HOME/

# Set up Vim
## Vundle (Vim package manager)
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
### Then go to https://github.com/VundleVim/Vundle.vim
### Deactivate your firewall (just in case), launch Vim and run:
:PluginInstall
## Install YouCompleteMe by reading
## https://github.com/Valloric/YouCompleteMe/blob/master/README.md#ubuntu-linux-x64
## (no need to read the "Full Installation Guide" section; if you alreadt have Clang
## on your system, your might use the option `--system-libclang`)

zsh-newuser-install
```

4. Check *Additional Drivers* in *Settings* to make sure all devices are being used.

5. Set the keyboard layout to US international with dead keys.

5. Set up the xfce panel (top bar): show the battery indicator (if on a laptop), set the date, time and timezone, sync the time with the Internet. Add network, RAM and CPU monitor.

6. Go through all the settings, in the *Settings Manager*.

    - More importantly, set the keyboard shortcuts (*Tile window to the x*, *Show desktop*). Also, set:
        
        - Shift Alt 4: `xfce4-screenshooter -r`
        - Ctrl Shift Alt 4: `xfce4-screenshooter -c -r`

    - Also, change the DNS servers to those from FDN (http://blog.fdn.fr/?post/2014/12/07/Filtrer-The-Pirate-Bay-Ubu-roi-des-Internets).
    - Set up your `/etc/hosts`: [https://github.com/rpellerin/safe-hosts](https://github.com/rpellerin/safe-hosts).
    - Finally, in *Keyboard*, bind the command `/home/romain/git/dotfiles/scripts/lock-screen.sh` with *Ctrl+Alt+Delete*.

7. Set up **Thunderbird**. Most of the time, you can import the directory *~/.thunderbird* (except the directory *Crash Reports*, inside, maybe) from another computer. In Preferences > Advanced > General > Config Editor, set `rss.show.content-base` to 1 so that RSS feeds opened in a new tab will always show summaries instead of loading the full web page.

8. Install the [ownCloud client](https://software.opensuse.org/download/package?project=isv:ownCloud:desktop&package=owncloud-client). **UPDATE**: install NextCloud instead of ownCloud.

9. You shoud install f.lux and launch it at startup (Menu>Settings>Session and startup): http://doc.ubuntu-fr.org/f.lux#installation_manuelle

10. Make sure nothing happens when you close the lid (in both plugged mode or battery mode): no sleep mode, no turning off.

11. [You might want to protect your privacy even further](http://blog.romainpellerin.eu/yes-privacy-matters.html) (read the section "Further Reading"). Also read [this](https://spreadprivacy.com/linux-privacy-tips/).

12. If you experience V-sync issues when watching [this video](https://www.youtube.com/watch?v=0RvIbVmCOxg), you might want to install [compton](http://duncanlock.net/blog/2013/06/07/how-to-switch-to-compton-for-beautiful-tear-free-compositing-in-xfce/), unless you run [`xfwm4` 4.13+](https://github.com/xfce-mirror/xfwm4/blob/master/COMPOSITOR).

13. Also consider disabling guest sessions:

    ```bash
    sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
    ```

14. Disable Bluetooth on startup: disable blueman applet from application autostart cause its turns bluetooth on when starting. Then run `sudo systemctl disable bluetooth`. To check status, run one of the following commands:

    - `hcitool dev`
    - `rfkill list`
    - `bluetooth`


15. Install VS Code from the official website: [https://code.visualstudio.com/](https://code.visualstudio.com/). Suggested extensions are:

    - esbenp.prettier-vscode
    - dbaeumer.vscode-eslint
    - eamodio.gitlens

    Then, run `ln -s $REPO_DIR/.config/Code/User/* $HOME/.config/Code/User/`.

## Create a GPG key

Only if you don't have one already.

For Github to verify your commits, mostly. Also useful for `pass`.

```bash
gpg2 --full-gen-key # Accept RSA and RSA, size 4096
```

[More details](https://help.github.com/articles/signing-commits-with-gpg/).

## Optional stuff

### Hardening security

Check [this](https://korben.info/attaquant-prendre-controle-total-dune-machine-30-secondes-grace-a-intel-amt.html) out if own a laptop equiped with an Intel CPU and ATM (Active Management Technology).

### Android

Pay attention while installing the Android SDK, it requires extra Debian packages, as stated on the download page. You'll also need to install `lib32stdc++6` and `lib32z1`.

Then:

    ```bash
    mkdir -p $HOME/.gradle
    cp $REPO_DIR/.gradle/gradle.properties $HOME/.gradle/

    sudo ln -s /home/romain/android-studio/bin/studio.sh /usr/local/bin/studio
    sudo ln -s /home/romain/Android/Sdk/tools/android /usr/local/bin/android
    ```

### Python 3.5

If you download Python3 using your package manager (as seen above), you'll likely get a quite old version. If you want the latest one, here's how to do it:

1. Download it from [https://www.python.org/downloads/](https://www.python.org/downloads/)
2. Extract the tar ball and `cd` to the directory.
3. Then:

    ```bash
    sudo apt install libssl-dev openssl libsqlite3-dev
    ./configure --enable-loadable-sqlite-extensions --with-ensurepip=install
    make profile-opt
    make test
    sudo make install
    ```

You might also consider using [Pipenv](https://github.com/pyenv/pyenv-virtualenv) to manage several versions of Python and virtual environments.

```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
```

### Optional Python packages

Installable with `pip install <package>`. [Don't run them as `sudo`](https://pages.charlesreid1.com/dont-sudo-pip/).

- `eg` useful examples of common commands
- `gitpython` an API for GitHub

### Install Rust and `exa` (a better `ls`)

```bash
curl https://sh.rustup.rs -sSf | sh
```

[More details](https://www.rust-lang.org/en-US/install.html).

Now install `exa`:

```bash
cargo install exa
```

### TeamViewer

```bash
wget http://download.teamviewer.com/download/teamviewer_linux.deb -O /tmp/teamviewer.deb
sudo dpkg -i /tmp/teamviewer.deb
# You might need to run dpkg --add-architecture i386 before the previous command
sudo apt update # Required to solve dependencies involving i386 packages
sudo apt install -f
rm /tmp/teamviewer.deb -f
```


### Haskell & Pandoc

```bash
sudo apt install haskell-platform
# http://pandoc.org/installing.html
cabal update
cabal install pandoc --enable-tests
cabal install pandoc-citeproc
```


### Optional Debian/Ubuntu packages

- `exiftool` for EXIF data
- `jhead` for EXIF data
- `filezilla`
- `zenity` a simple interactive dialog
- `icoutils` to create Microsoft Windows(R) icon and cursor files
- `zathura` a PDF viewer
- `wireshark`
- `htop`
- `synaptic` see http://askubuntu.com/questions/76/whats-the-difference-between-package-managers
- `gtk-recordmydesktop`
- `pdf-presenter-console`
- `openvpn`
- `network-manager-openvpn-gnome` (then `sudo service network-manager restart`)
- `network-manager-vpnc`
- `codeblocks`

### Optional npm packages

Installable with `npm install -g <package>`.

- `eslint` Linter for JavaScript, read [http://eslint.org/docs/user-guide/getting-started](http://eslint.org/docs/user-guide/getting-started)
- `cloc` Count Lines of Code
- `sloc` Source Line Of Code (same stuff)
- `gnomon` Utility to annotate console logging statements with timestamps
- `livedown` Live preview of Markdown files
- `peerflix` Download torrent and watch them as they are being downloaded
- `castnow` Play media files on Chromecast (subtitles supported)
