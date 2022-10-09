## What to do before reformating a computer?

Back up, just in case, the following:

- Passwords in clear, just in case the GPG keys restoration fails. VERY UNSAFE, as it exposes your passwords in clear text though.

  ```bash
  cd .password-store
  find . -type f -iname "*.gpg" -printf '%P\n' | sed 's/\.gpg$//' | while read line; do echo "$line:$(pass show $line)"; done > /tmp/pass.backup
  ```

- Bookmarks in Firefox
- cron jobs
- The content of `$HOME/` (except for `.cache` and other non important folders), especially:

  - `.zsh_history`
  - `.config/`
  - `.password-store/`
  - `.gitconfig_local`
  - `Documents/`, `Downloads/`, `Pictures/`, `~/snap/thunderbird/common/.thunderbird`
  - SSH and GPG keys (`$HOME/.ssh`, `$HOME/.gnupg`)

When reinstalling Xubuntu, use encrypted LVM on a ext4 filesystem (not ZFS). After the install, [we'll resize the SWAP partition](https://romainpellerin.eu/how-to-resize-an-encrypted-swap-partition-lvm.html), as by default it's too small (less than 1G).

# What to do after a fresh install of Xubuntu?

![How to secure your laptop](https://raw.githubusercontent.com/rpellerin/dotfiles/master/Pictures/secure-laptop.png)

## 1. BIOS and Grub

_Side note_: leaving Secure Boot on is fine, as long as you select "Enroll MOK" after rebooting, following the install.

Upgrade the bios by downloading the latest image from [Dell.com](http://www.dell.com/support/home/us/en/19/product-support/product/latitude-14-7480-laptop/drivers?os=biosa). (Alternatively, you can try to download the image from [this website](https://fwupd.org/lvfs/devicelist) and install it through "Software" (simply open the file).) Then:

```bash
sudo cp Downloads/Latitude_7x80_1.4.6.exe /boot/efi # Not mv because of permissions
rm Downloads/Latitude_7x80_1.4.6.exe
```

Reboot, hit F12 to initiate the update. Once done, reboot and press F2 to enter BIOS setup. Set a password for the BIOS and the hard drive. [Disable Bluetooth in Advanced > Devices > Onboard](https://www.dell.com/community/Inspiron/Disabling-Bluetooth-from-BIOS/td-p/8069806). Don't forget to remove the file from `/boot/efi` on the next boot.

## 2. First steps and essential packages

1. Copy all the files you backed up.
2. In Thunar, show hidden files.

### Packages to install

```bash
# https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

sudo apt-add-repository ppa:git-core/ppa
sudo add-apt-repository ppa:nextcloud-devs/client
sudo apt update
sudo apt upgrade
sudo apt install gnupg2 \
    apt-listchanges \
    tmux \
    python3-venv \
    xfce4-systemload-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    ristretto \
    git git-extras \
    nextcloud-client \
    htop \
    evince \
    python3-pip \
    xclip \
    autojump \
    tree \
    jq \
    tumbler-plugins-extra \
    imagemagick \
    inotify-tools \
    mousepad \
    vlc \
    build-essential \
    gimp \
    curl \
    ffmpeg \
    vim-gtk3 \
    zsh \
    p7zip-full \
    libreoffice \
    libreoffice-l10n-fr \
    libreoffice-l10n-en-gb \
    libreoffice-help-en-gb \
    libreoffice-help-fr \
    unattended-upgrades \
    redshift-gtk \
    simplescreenrecorder \
    thunar-archive-plugin \
    openvpn \
    network-manager-openvpn-gnome \
    network-manager-vpnc \
    cryptsetup \
    ecryptfs-utils

sudo dpkg-reconfigure unattended-upgrades
```

### Explanations

- `cryptsetup` is to be able to [open LUKS-encrypted disks](https://romainpellerin.eu/yes-privacy-matters.html#encrypt-external-hdd-with-dm-crypt-and-luks), with: `sudo cryptsetup luksOpen /dev/sda1 ext-hdd`
- `ecryptfs-utils` is to be able to open ecryptfs-encrypted folders, with: `sudo mount -t ecryptfs srcFolder destFolder`
- `evince` is a PDF viewer
- `tumbler-plugins-extra` is to get Thunar to show video thumbnails
- An alternative to autojump is `z`: https://github.com/rupa/z
- `vim-gtk3` brings clipboard support
- `redshift-gtk` is an alternative to xflux

### VPN files

Add `.ovpn` files to the systray: `nmcli connection import type openvpn file <file>`

## 3. Optional packages

```bash
sudo apt install texlive-full \
    texlive-bibtex-extra \
    biber \
    arandr \
    gigolo \
    mpd mpv \
    exiftool \
    jhead \
    ncdu \
    ntp \
    optipng \
    filezilla
    zenity \
    icoutils \
    silversearcher-ag \
    synaptic \
    libreoffice-pdfimport \
    hyphen-fr \
    hyphen-en-gb \
    hunspell-en-gb \
    pdf-presenter-console
```

### Explanation

- `libreoffice-pdfimport` is for PDF signing
- `mpd` is a music player for terminal, `mpv` is a video player compatible with Youtube and co.
- `exiftool` and `jhead` are for EXIF data
- `zenity` is a simple interactive dialog
- `icoutils` to create Microsoft Windows(R) icon and cursor files
- `synaptic`: see http://askubuntu.com/questions/76/whats-the-difference-between-package-managers

## 4. Pass, SSH and GPG keys

### Pass

#### Prerequisite

```bash
sudo apt install oathtool dmenu # oathtool for OTPs, dmenu for passmenu
```

#### Installation

```bash
sudo apt install pass pass-extension-otp
```

### SSH

```bash
ssh-keygen -t rsa -b 4096 -C "<public github email address>" -f .ssh/id_rsa
cat .ssh/id_rsa.pub | xclip -i -selection clip-board
```

Paste what you just copied at [https://github.com/settings/keys](https://github.com/settings/keys)

### GPG

Only if you don't have one already. For Github to verify your commits, mostly. Also useful for `pass`.

Make sure to run `sudo chmod go-rwx .gnupg` before doing anything else.

```bash
gpg2 --full-gen-key # Accept RSA and RSA, size 4096
gpg2 --list-secret-keys --keyid-format LONG # Copy the value after `sec rsa4096/`
gpg2 --edit-key <copied value>

# Now we'll create a signing subkey
addKey
4
4096
5y
y
y
save

gpg2 --gen-revoke <copied value> > revoke.asc
gpg2 -c revoke.asc
echo "  signingkey = <copied value>" >> ~/.gitconfig_local
gpg2 --armor --export <copied value> | xclip -i -selection clip-board
```

Paste what you just copied at [https://github.com/settings/keys](https://github.com/settings/keys). [More details](https://help.github.com/articles/signing-commits-with-gpg/).

It's also very important to make backups of your private and public keys:

```bash
gpg2 --armor --export-secret-keys "Romain" > secret.key
gpg2 --armor --export "Romain" > public.key # --export-secret-keys also exports public keys, but just in case
gpg2 --armor --export-secret-subkeys <copied value> > subkeys.key # --export-secret-keys also exports subkeys, but just in case
gpg2 --export-ownertrust > romain-ownertrust-gpg.txt
gpg2 -c secret.key # Encrypt your private key before saving it somewhere. Also save your ~/.gnupg/gpg.conf
```

To restore it:

```bash
gpg2 -d secret.key.gpg # Decrypt private key
gpg2 --import secret.key
gpg2 --import public.key # Is this needed?
gpg2 --import-ownertrust romain-ownertrust-gpg.txt
# Or, if you don't have the ownertrust file
gpg2 --edit-key "Romain"
trust
5
save
```

If you have made backups and created a signing subkey, it's reasonably safe to remove the master key from your machine. You only need the master key to sign other people's key or edit your subkeys.

```bash
gpg2 --delete-secret-key <copied value>
gpg2 --import subkeys.key
shred -u subkeys # for security purposes
```

To temporarily re-import it, do:

```bash
mkdir ~/gpgtmp
gpg2 --homedir ~/gpgtmp --import secret.txt
# Do what you need to with `gpg2 --homedir ~/gpgtmp command`
gpg-connect-agent --homedir ~/gpgtmp KILLAGENT /bye
rm -rf ~/gpgtmp
```

If, for some reason, you want to erase all your secret and public keys, run:

```
gpg2 --delete-secret-and-public-key <copied value>
```

[More on restoring GPG keys here](https://lists.gnupg.org/pipermail/gnupg-users/2016-September/056735.html).

**Finally, configure Pass**:

```bash
pass init <copied value>
```

Set a cronjob to periodically make a backup:

```bash
0 20 9 * * tar czfh "/home/romain/$(date -u +"%Y-%m-%dT%H-%M-%SZ")-password-store.tar.gz" -C "$HOME" .password-store
```

### GPG + Git: signed commits

Put the following in `~/.gitconfig_local`:

```bash
[user]
	email = <public github email address>
	signingkey = <key associated with public github email address>
```

To get the IDs of available keys, run: `gpg2 --list-secret-keys --keyid-format LONG`. The ID is on a "sec" line, after "rsa4096/".

## 5. Google Chrome

### Google Chrome

Download the Chrome `.deb` file and then:

```bash
mv Downloads/google-chrome-stable.deb /tmp # Otherwise the line below will emit a warning
sudo apt install /tmp/google-chrome-stable.deb
rm -f /tmp/google-chrome-stable.deb
```

### Chromium

[Note that you won't be able to sync your Google account with Chromium.](https://askubuntu.com/questions/1322559/sync-chromium-with-a-google-account-does-not-work-any-more-solutions)

```bash
snap install chromium
```

## 6. Visual Studio Code

[Download VS code .deb file](https://code.visualstudio.com/docs/setup/linux) and then:

```bash
mv Downloads/code_1.27_amd64.deb /tmp # Otherwise the line below will emit a warning
sudo apt install /tmp/code_1.27_amd64.deb
rm -f /tmp/code_1.27_amd64.deb
code --install-extension "esbenp.prettier-vscode"
code --install-extension "dbaeumer.vscode-eslint"
code --install-extension "eamodio.gitlens"
code --install-extension "rebornix.ruby"
code --install-extension "noku.rails-run-spec-vscode"
code --install-extension "sianglim.slim"
```

## 7. Firefox

[Disable the title bar](https://linuxconfig.org/how-to-remove-firefox-title-bar-on-linux).

Log in to your Firefox account.

- In [about:config](about:config), do:
  - Search for `vaapi` and change to `true`
  - If you want to disable the HTTP referer: set `network.http.sendRefererHeader` to `0` (note: this will break many websites, from my experience)
  - Set `view_source.wrap_long_lines` to `true`.
  - Set `browser.tabs.warnOnClose` to `false`.
  - Set `browser.tabs.closeWindowWithLastTab` to `false`.
  - Set `network.prefetch-next` to `false`.
  - Set `network.dns.disablePrefetch` to `true`.
  - Set `datareporting.healthreport.uploadEnabled` to `false`.
  - [If you don't care about Firefox remembering the zoom level you picked on a website basis](https://bugzilla.mozilla.org/show_bug.cgi?id=1377820), set `privacy.resistFingerprinting` to `true` (this voids the effect of `general.useragent.override`).
  - Set `gfx.webrender.enabled` to `true`.
  - Set `geo.enabled` to `false`.
  - Set `browser.safebrowsing.malware.enabled` to `false`.
  - Set `browser.safebrowsing.phishing.enabled` to `false`
  - Set `browser.send_pings` to `false`
  - Set `dom.battery.enabled` to `false`
  - Set `media.navigator.enabled` to `false`
  - Set `accessibility.blockautorefresh` to `true`
  - OPTIONAL: Set `network.trr.mode` to `2` ([https://blog.nightly.mozilla.org/2018/06/01/improving-dns-privacy-in-firefox/](https://blog.nightly.mozilla.org/2018/06/01/improving-dns-privacy-in-firefox/https://blog.nightly.mozilla.org/2018/06/01/improving-dns-privacy-in-firefox/) + [DNS-over-HTTPS functionality in Firefox](https://gist.github.com/bagder/5e29101079e9ac78920ba2fc718aceec)).
  - OPTIONAL: Set `network.trr.uri` to `https://mozilla.cloudflare-dns.com/dns-query` and [`network.security.esni.enabled` to `true`](https://korben.info/comment-activer-les-dns-via-https-dans-firefox.html).
  - OPTIONAL: Set `general.useragent.override` to `Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:80.0) Gecko/20100101 Firefox/80.0`
- In [about:preferences#general](about:preferences#general), check `Open previous windows and tabs` and unckeck `Ctrl+Tab cycles through tabs in recently used order`
- In [about:preferences#search](about:preferences#search), uncheck `Show search suggestions ahead of browsing history in address bar results`
- In [about:preferences#privacy](about:preferences#privacy), uncheck everything under `Firefox Data Collection and Use`. For `Enhanced Tracking Protection`, check `Strict`. Optionally, block cookies for trackers and the following domains:

  - https://s.ytimg.com
  - https://www.youtube.com
  - https://yt3.ggpht.com
  - https://www.google.com
  - https://www.google.fr
  - https://r5---sn-25glenes.googlevideo.com
  - https://i.ytimg.com
  - https://fonts.googleapis.com
  - https://i9.ytimg.com
  - https://r1---sn-25ge7ns7.googlevideo.com

  Make sure to be sending `Do Not Track` at all times.

- Add these extensions:
  - [Firefox Translations](https://addons.mozilla.org/en-US/firefox/addon/firefox-translations/)
  - [tabliss.io](https://tabliss.io/)
  - [React Developer Tools](https://addons.mozilla.org/en-US/firefox/addon/react-devtools)

## 8. Thunderbird

Before opening it up, to restore all email accounts, preferences and emails, you can import the directory `~/.thunderbird` from another computer. In the Settings, General > Config Editor\_, set `rss.show.content-base` to 1 so that RSS feeds opened in a new tab will always show summaries instead of loading the full web page.

To connect it to your Google address book, add a new CardDAV Address Book, and use this URL: `https://www.googleapis.com/carddav/v1/principals/USERNAME@gmail.com/lists/default/`

If using a Gmail account, under "Server Settings, in "Advanced Account Settings", fill "IMAP server directory" with "[Gmail]" (without the double quotes).

Don't forget to update the retention settings of folders, and where to save sent/draft/archives/deleted/etc emails.

## 9. ZSH + Prezto

```bash
zsh
# Press the 'q' key
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh # Now log out of your session and back in for this to take effect
```

At this point, CTRL+R and CTRL+T do not work. Step #22 (Fuzzy finder) will make it work.

## 10. NVM + NodeJS + a few packages

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# Make sure ~/.zshrc does not contain code added by nvm install script since it is already present in dotfiles/.rc
nvm install node
npm i -g tldr peerflix castnow # castnow plays media files on Chromecast (subtitles supported)
```

## 11. Firewall

```bash
cd dotfiles # cd to this git repo
sudo cp -i scripts/firewall.service /etc/systemd/system/
sudo chmod 700 /etc/systemd/system/firewall.service
sudo chown root:root /etc/systemd/system/firewall.service
sudo systemctl enable firewall
```

## 12. Custom conf files

```bash
cd dotfiles # cd to this git repo
REPO_DIR=`pwd`

# Custom settings
ln -sf $REPO_DIR/.vimrc $HOME/
echo "source $REPO_DIR/.rc" >> $HOME/.zshrc
echo "source $REPO_DIR/.aliases" >> $HOME/.zshrc
ln -sf $REPO_DIR/.tmux.conf $HOME/
mkdir -p $HOME/.config/autostart
cp $REPO_DIR/.config/autostart/* "$HOME/.config/autostart"
cp "$REPO_DIR/.config/redshift.conf" $HOME/.config/
mkdir -p $HOME/.config/Code/User/
ln -s $REPO_DIR/.config/Code/User/* $HOME/.config/Code/User/
ln -sf "$REPO_DIR/.gitconfig" $HOME/
ln -sf "$REPO_DIR/.git-templates" $HOME/
ln -sf "$REPO_DIR/.gitignore_global" $HOME/
ln -sf $REPO_DIR/.curlrc $HOME/
ln -sf $REPO_DIR/.less $HOME/
ln -sf $REPO_DIR/.lesskey $HOME/
mkdir -p $HOME/.gnupg
ln -s $REPO_DIR/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf

source "$REPO_DIR/.rc"
git diff $HOME/.zprezto/runcoms/zpreztorc $REPO_DIR/.zpreztorc # Check nothing is new/unusual
ln -s "$REPO_DIR/.zpreztorc" $HOME/

sudo su
echo 'KERNEL=="card0", SUBSYSTEM=="drm", ACTION=="change", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/romain/.Xauthority", RUN+="/home/romain/git/dotfiles/scripts/hdmi_sound_toggle.sh"' > /etc/udev/rules.d/99-hdmi_sound.rules
sudo udevadm control --reload-rules
sudo systemctl restart udev
```

## 13. Edit terminal preferences

- In `General`, unlimited scrollback. Disable the scrollbar being shown.
- In `Appearance`, uncheck menu bar and borders around new windows. Set the font size to 13.
- In `Colors`, use the `Xubuntu dark` theme, check `Cursor color` and leave the default one.

## 14. Set up Vim

Just open Vim once and let Vim-Plug install all of the listed plugins.

## 15. All settings

On the desktop, right click, "Desktop Settings". In the tab "Icons", hide the Home folder icon.

Open the settings manager and do:

- Click _Additional Drivers_ to make sure all devices are being used.
- Set the keyboard layout to US international with dead keys.
- Set up the xfce panel (top bar): show the battery indicator (if on a laptop), set the date, time and timezone (clock format: `%a %d %b %T %p`), sync the time with the Internet. Add network, RAM and CPU monitor.
- In `Window Manager` > `Keyboard`, set the keyboard shortcuts (_Tile window to the x_, _Show desktop_).
- In `Screensaver`:

  - In the tab "Screensaver", enable the screensaver. Pick the "Blank Screen" option, and changes its settings to 10 seconds for "After blanking, put display to sleep after" and "Never" for "After sleeping, switch display off after". Active the screensaver when computer is idle after 1 minutes. Check "Inhibit screensaver for fullscreen applications".
  - In the tab "Lock Screen", enable everything except "On Screen Keyboard" and "Logout".

- In `Display`, in the tab `Advanced`, create a profile for when connected to a TV for instance, and enable both `Configure new displays when connected` and `Automatically enable profiles when new display is connected`
- In `Keyboard` > `Application Shortcuts`, set:

  - Super A: `/home/romain/git/dotfiles/scripts/passmenu`
  - Super C: `google-chrome`
  - Shift Alt 4: `xfce4-screenshooter -r`
  - Ctrl Shift Alt 4: `xfce4-screenshooter -c -r`
  - Ctrl Q: `true`
  - Email client to `Super + M`
  - Browser to `Super + W`
  - File explorer to `Super + F`
  - Super + T: `xfce4-terminal --default-working-directory=/some/path`
  - Super + S: `slack`
  - Super + L: `/home/romain/git/dotfiles/scripts/screen-off-and-lock.sh`
  - Ctrl F8: `xdg-open "https://twitter.com/"`
  - Ctrl F9: `/home/romain/git/dotfiles/scripts/copy-no-break-line.sh`
  - Ctrl F12: `/home/romain/git/dotfiles/scripts/mprisctl.sh play-pause`
  - F8: `/home/romain/git/dotfiles/scripts/hdmi_sound_toggle.sh`

  The layout is likely 105 key (intl) (check with `cat /etc/default/keyboard`). Set the repeat delay to 350ms and the repeat speed to 35.

- In `Power manager`:

  - In the tab "General": "disable all switch buttons ("Handle display brightness keys" and all under "Appearance"), set "Do nothing" everywhere except for "When power button is pressed", pick "Ask".
  - In the tab "System", for both "On battery" and "Plugged in", make sure nothing happens when you close the lid, just switch off display. Set the suspend mode to "Never". Critical battery power level on 3% should suspend. Make sure to tick "Lock screen when system is going to sleep".
  - In the tab "Display", for both "On battery" and "Plugged in", "Blank after" never, "Put to sleep after" never, and "Switch off after" never. "Reduce brightness after" never. Yet, **leave "Display power management" on, as otherwise the screensaver won't be able to turn off the screen.**

- In `Removable Drives and Media`, uncheck the 3 options about auto-mount and auto-browse.
- In `Notifications`, log all notifications but not applications.
- In `Mouse and Touchpad`, set the duration for `Disable touchpad while typing` to 0.4s. Also enable horizontal scrolling.

## 16. Disable auto change of sound output when plugging in an external monitor

In `/etc/pulse/default.pa`, comment these lines:

```text
#.ifexists module-switch-on-connect.so
#load-module module-switch-on-connect
#.endif
```

## 17. Disabling Bluetooth on startup

In #1 we saw how to hardware disable it. Here we have a look at software disabling it.

Disable blueman applet from application autostart cause it turns bluetooth on when starting. Then run `sudo systemctl disable bluetooth`. To check status, run one of the following commands:

    - `hcitool dev`
    - `rfkill list`
    - `bluetooth`

## 18. Fuzzy finder

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --no-update-rc
```

## 19. Hardening security and checking for malwares

```bash
sudo apt install rkhunter lynis chkrootkit

sudo cp  /etc/rkhunter.conf /etc/rkhunter.conf.local
# In /etc/rkhunter.conf.local set `WEB_CMD=curl` and `PKGMGR=DPKG`
sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check

sudo lynis update info
sudo lynis audit system

sudo chkrootkit
```

It is advised to run these tools daily as cron jobs.

## 20. Allow PDF edition

In `/etc/ImageMagick-6/policy.xml`, comment out the last 6 lines:

    :::xml
    <!-- <policy domain="coder" rights="none" pattern="PS" />
    <policy domain="coder" rights="none" pattern="PS2" />
    <policy domain="coder" rights="none" pattern="PS3" />
    <policy domain="coder" rights="none" pattern="EPS" />
    <policy domain="coder" rights="none" pattern="PDF" />
    <policy domain="coder" rights="none" pattern="XPS" /> -->

And increase this line to 8GiB:

    :::xml
    <policy domain="resource" name="disk" value="8GiB"/>

## Optional stuff

### Battery saver (https://doc.ubuntu-fr.org/tlp)

```bash
sudo apt install tlp
sudo systemctl enable tlp
sudo systemctl enable tlp-sleep
```

### Improving privacy

Change the DNS servers to those from FDN (http://blog.fdn.fr/?post/2014/12/07/Filtrer-The-Pirate-Bay-Ubu-roi-des-Internets). Go to Settings > Network.

Set up your `/etc/hosts`: [https://github.com/rpellerin/safe-hosts](https://github.com/rpellerin/safe-hosts).

[You might want to protect your privacy even further](https://romainpellerin.eu/yes-privacy-matters.html) (read the section "Further Reading"). Also read [this](https://spreadprivacy.com/linux-privacy-tips/).

### Hardening security

Check [this](https://korben.info/attaquant-prendre-controle-total-dune-machine-30-secondes-grace-a-intel-amt.html) out if you own a laptop equiped with an Intel CPU and ATM (Active Management Technology).

### Install Rust

```bash
curl https://sh.rustup.rs -sSf | sh
```

[More details](https://www.rust-lang.org/en-US/install.html).

#### `exa` (a better `ls`)

Now install `exa`:

```bash
sudo apt install zlib1g-dev
cargo install exa
```

#### `bat` (a better `cat`)

```bash
cargo install bat
```

#### Optional Python packages

Installable with `python3 -m pip install -U <package>`. [Don't run them as `sudo`](https://pages.charlesreid1.com/dont-sudo-pip/).

- `eg` useful examples of common commands
- `gitpython` an API for GitHub
- `yt-dlp`: a video downloader

### TeamViewer

```bash
wget http://download.teamviewer.com/download/teamviewer_linux.deb -O /tmp/teamviewer.deb
sudo dpkg -i /tmp/teamviewer.deb
# You might need to run dpkg --add-architecture i386 before the previous command
sudo apt update # Required to solve dependencies involving i386 packages
sudo apt install -f
rm /tmp/teamviewer.deb -f
```

### Haskell & Pandoc

```bash
sudo apt install haskell-platform
```

Or, better:

```bash
sudo apt install curl g++ gcc libgmp-dev libtinfo-dev make ncurses-dev python3 coreutils xz-utils zlib1g-dev build-essential libnuma-dev
# https://github.com/haskell/ghcup/issues/64
# https://github.com/haskell/ghcup/issues/31
curl https://raw.githubusercontent.com/haskell/ghcup/master/bootstrap-haskell -sSf | sh
cabal new-install cabal-install
```

Then:

```bash
# http://pandoc.org/installing.html
cabal update
cabal install pandoc --enable-tests
cabal install pandoc-citeproc
```
