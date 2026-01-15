# Foreword on Dell Latitude 7480, 7490

[A known bug](https://www.dell.com/community/Latitude/Anyone-else-having-freezing-issues-with-Dell-Latitude-7490-s/td-p/7307897/page/9) affects the 74xx line of Dell products: when picked up with the left side, the laptop sometimes freezes and crashes. Common answers suggest the following solutions:

1. Unscrew the back of the laptop (bottom) and reseat the memory modules (RAM)
1. Same but reseat the SSD
1. If none of the above worked, set [this kernel parameter](https://wiki.archlinux.org/title/intel_graphics): `i915.enable_dc=0`

# What to do before reformating a computer?

Back up the following:

- Passwords in clear, just in case the GPG keys restoration fails. VERY UNSAFE, as it exposes your passwords in clear text though.

  ```bash
  cd ~/.password-store
  find . -type f -iname "*.gpg" -printf '%P\n' | sed 's/\.gpg$//' | while read line; do echo "$line:$(pass show $line)"; done > ~/Downloads/pass.backup
  ```

- Back up your [Firefox profile](https://support.mozilla.org/en-US/kb/back-and-restore-information-firefox-profiles) and [Thunderbird profile](https://support.mozilla.org/en-US/kb/thunderbird-export)
- cron jobs: `crontab -l > ~/Downloads/cronjobs.backup`
- Some folders/files from `$HOME/`:

  - `.config/` (you probably won't need it, just in case)
  - `.password-store/`
  - SSH and GPG keys (`$HOME/.ssh`, `$HOME/.gnupg`)
  - `Desktop/`, `Documents/`, `Downloads/`, `Pictures/`, `Videos/`
  - `.gitconfig_local`
  - `.private_aliases`
  - `.zsh_history`
  - `~/snap/thunderbird/common/.thunderbird`, `~/snap/firefox/common/.mozilla/firefox/` (just in case the profile import fails later)
  - `~HOME/git/` does not need to be backed up, everything should be present on GitHub.

# Installing Xubuntu

_Side note_: leaving Secure Boot on during the install process is fine, as long as you select "Enroll MOK" after rebooting, following the install.

Download the minimal Xubuntu ISO file (not the classic one) and copy it onto a USB stick using `dd`.

If using a Lenovo Thinkpad Gen 5 or newer, before booting off the USB stick, you have to enable "Allow Microsoft 3rd Party UEFI CA" in the BIOS -> Security -> Secure Boot. ([source](https://askubuntu.com/a/1528808))

Tick both "third-party software for graphics and Wi-Fi hardware" and "support for additional media formats" during the install.

Use encrypted LVM on a ext4 filesystem (not ZFS). After the install, [we'll resize the SWAP partition](https://romainpellerin.eu/how-to-resize-an-encrypted-swap-partition-lvm.html), as by default it's too small (less than 1G).

# What to do after a fresh install of Xubuntu?

1. Copy all the files you backed up, restore `$HOME/.ssh`.
2. In Thunar, show hidden files.
3. `git clone git@github.com:rpellerin/dotfiles.git`

## Packages to install

```bash
# https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# To avoid being spammed with updates during the day
snap set system refresh.timer=4:00-7:00

sudo apt-add-repository ppa:git-core/ppa
sudo apt update
sudo apt upgrade

snap refresh
snap install firefox
snap install thunderbird

# Do not install Slack as snap, as there are two bugs, still unresolved as of 2024:
# - https://forum.snapcraft.io/t/slack-snap-window-has-no-icon/3589/13
# - https://www.reddit.com/r/Slack/comments/uw8vxp/when_i_rightclick_to_copy_a_link_slack_hangs_for/

sudo apt install gnupg2 \
    xsel \
    libspa-0.2-bluetooth \
    ibus \
    openjdk-21-jdk \
    apt-listchanges \
    tmux \
    python3-full python3-pip python3-venv \
    xfce4-systemload-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    ristretto \
    git git-extras \
    htop \
    evince \
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
    cmake \
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
    zenity \
    thunar-archive-plugin \
    openvpn \
    network-manager-openvpn-gnome \
    network-manager-vpnc \
    cryptsetup \
    ecryptfs-utils \
    blueman

sudo dpkg-reconfigure unattended-upgrades
python3 -m venv ~/python-venv --system-site-packages
```

### Explanations

- `libspa-0.2-bluetooth` might be useless, but on 24.04 I had to install this for my bluetooth earphones to connect
- `ibus` is to add emojis through `Super+.`
- `cryptsetup` is to be able to [open LUKS-encrypted disks](https://romainpellerin.eu/yes-privacy-matters.html#encrypt-external-hdd-with-dm-crypt-and-luks), with: `sudo cryptsetup luksOpen /dev/sda1 ext-hdd`
- `xsel` is for clipboard features
- `ecryptfs-utils` is to be able to open ecryptfs-encrypted folders, with: `sudo mount -t ecryptfs srcFolder destFolder`
- `evince` is a PDF viewer
- `tumbler-plugins-extra` is to get Thunar to show video thumbnails
- An alternative to autojump is `z`: https://github.com/rupa/z
- `vim-gtk3` brings clipboard support
- `redshift-gtk` is an alternative to xflux
- `zenity` is a simple interactive dialog

## VPN files

Add a VPN file through the systray, by clicking on the Wifi icon, then VPN Connections > Configure VPN... > Add a new connection > Import a saved VPN configuration...

Alternatively, add `.ovpn` files to the systray: `nmcli connection import type openvpn file <file>`

## Optional packages

```bash
sudo apt install texlive-full \
    texlive-bibtex-extra \
    biber \
    arandr \
    gigolo \
    mpd \
    mpv \
    exiftool \
    jhead \
    ncdu \
    ntp \
    optipng \
    icoutils \
    silversearcher-ag \
    synaptic \
    libreoffice-pdfimport \
    hyphen-fr \
    hyphen-en-gb \
    hunspell-en-gb \
    pdf-presenter-console

# mpv will install yt-dlp (`aptitude why yt-dlp`), we must remove it and install it later through pip
sudo apt purge yt-dlp
```

### Explanation

- `libreoffice-pdfimport` is for PDF signing
- `mpd` is a music player for terminal
- `mpv` is a video player compatible with Youtube and co. It is also better than VLC when it comes to displaying HDR videos.
- `exiftool` and `jhead` are for EXIF data
- `icoutils` to create Microsoft Windows(R) icon and cursor files
- `synaptic`: see http://askubuntu.com/questions/76/whats-the-difference-between-package-managers

## Pass, SSH and GPG keys

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
0 20 9 * * tar czfh "/home/romain/Documents/$(date -u +"%Y-%m-%dT%H-%M-%SZ")-password-store.tar.gz" -C "$HOME" .password-store
```

### GPG + Git: signed commits

Put the following in `~/.gitconfig_local`:

```bash
[user]
	email = <public github email address>
	signingkey = <key associated with public github email address>
```

To get the IDs of available keys, run: `gpg2 --list-secret-keys --keyid-format LONG`. The ID is on a "sec" line, after "rsa4096/".

## Google Chrome

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

## Visual Studio Code

[Install VS code](https://code.visualstudio.com/docs/setup/linux#_snap): `snap install --classic code`

```bash
code --install-extension "esbenp.prettier-vscode"
code --install-extension "ruby-syntax-tree.vscode-syntax-tree"
code --install-extension "dbaeumer.vscode-eslint"
code --install-extension "eamodio.gitlens"
code --install-extension "Shopify.ruby-lsp"
code --install-extension "noku.rails-run-spec-vscode"
code --install-extension "GitHub.copilot"
code --install-extension "jasonnutter.vscode-codeowners"
code --install-extension "misogi.ruby-rubocop"
code --install-extension "bradlc.vscode-tailwindcss"
code --install-extension "sianglim.slim"
```

## Firefox

If Firefox fails to reuse your restored profile(s), launch it with `firefox --ProfileManager`.

[Disable the title bar](https://linuxconfig.org/how-to-remove-firefox-title-bar-on-linux).

Log in to your Firefox account.

- In [about:config](about:config), do:
  - Search for `media.ffmpeg.vaapi.enabled` and change to `true`
  - Add `places.history.expiration.max_pages` and set it to 10000000
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
- In [about:preferences#privacy](about:preferences#privacy), uncheck everything under `Firefox Data Collection and Use`. Check `Enable HTTPS-Only Mode in all windows`. For `Enhanced Tracking Protection`, check `Strict`. Make sure to be sending `Do Not Track` at all times.

- Add these extensions:
  - [Firefox Translations](https://addons.mozilla.org/en-US/firefox/addon/firefox-translations/)
  - [tabliss.io](https://tabliss.io/)
  - [React Developer Tools](https://addons.mozilla.org/en-US/firefox/addon/react-devtools)

## Thunderbird

Before opening it up, to restore all email accounts, preferences and emails, you can import the directory `~/snap/thunderbird/common/.thunderbird` from another computer. When launching Thunderbird, if it fails to use your restored profile(s), launch it with `thunderbird --ProfileManager`.

In the Settings, General > Config Editor, set `rss.show.content-base` to 1 so that RSS feeds opened in a new tab will always show summaries instead of loading the full web page.

To connect it to your Google address book, add a new CardDAV Address Book, and use this URL: `https://www.googleapis.com/carddav/v1/principals/USERNAME@gmail.com/lists/default/`

If using a Gmail account, under "Server Settings, in "Advanced Account Settings", fill "IMAP server directory" with "[Gmail]" (without the double quotes).

Don't forget to update the retention settings of folders, and where to save sent/draft/archives/deleted/etc emails.

## ZSH + Prezto

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

At this point, CTRL+R and CTRL+T do not work. Step #18 (Fuzzy finder) will make it work.

## [mise](https://github.com/jdx/mise) (replaces [NVM](https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script)) + NodeJS

```bash
curl https://mise.run | sh
# Make sure ~/.zshrc does not contain code added by mise install script since it is already present in dotfiles/.rc

# Open a new terminal
mise doctor # Check that it works
mise use --global node
```

## Firewall (not recommended anymore - fairly useless on a desktop)

```bash
cd dotfiles # cd to this git repo
sudo cp -i scripts/firewall.service /etc/systemd/system/
sudo chmod 700 /etc/systemd/system/firewall.service
sudo chown root:root /etc/systemd/system/firewall.service
sudo systemctl enable firewall
```

## Custom conf files

```bash
cd dotfiles # cd to this git repo
REPO_DIR=`pwd`
JAVA_HOME=$(readlink -f `which javac` | sed "s:/bin/javac::")

# Custom settings
echo "export JAVA_HOME=$JAVA_HOME" >> $HOME/.zshrc
mkdir -p $HOME/.gnupg
chmod go-rwx .gnupg
chmod og-r $HOME/.ssh/id_rsa
chmod og-r $HOME/.ssh/known_hosts
chmod og-r $HOME/.ssh/known_hosts.old
ln -sf $REPO_DIR/.vimrc $HOME/
echo "source $REPO_DIR/.rc" >> $HOME/.zshrc
echo "source $REPO_DIR/.aliases" >> $HOME/.zshrc
touch "$REPO_DIR/.private_aliases"
ln -sf $REPO_DIR/.tmux.conf $HOME/
mkdir -p $HOME/.config/autostart
cp $REPO_DIR/.config/autostart/* "$HOME/.config/autostart"
cp "$REPO_DIR/.config/redshift.conf" $HOME/.config/
mkdir -p $HOME/.config/Code/User/
ln -sf $REPO_DIR/.config/Code/User/* $HOME/.config/Code/User/
ln -sf "$REPO_DIR/.gitconfig" $HOME/
ln -sf "$REPO_DIR/.git-templates" $HOME/
ln -sf "$REPO_DIR/.gitignore_global" $HOME/
ln -sf $REPO_DIR/.curlrc $HOME/
ln -sf $REPO_DIR/.less $HOME/
ln -sf $REPO_DIR/.lesskey $HOME/
ln -s $REPO_DIR/.gnupg/gpg.conf $HOME/.gnupg/gpg.conf

source "$REPO_DIR/.rc"
git diff $HOME/.zprezto/runcoms/zpreztorc $REPO_DIR/.zpreztorc # Check nothing is new/unusual
ln -sf "$REPO_DIR/.zpreztorc" $HOME/

# Bring back your backup of `.zsh_history`, and put it in `$HOME/.zsh_history`.
```

## Update BIOS

Connec the laptop to AC power, then:

```bash
maj-bios
```

### Alternative (old way)

You can also update the BIOS by downloading the latest image from [Dell.com](http://www.dell.com/support/home/us/en/19/product-support/product/latitude-14-7480-laptop/drivers?os=biosa). (Alternatively, you can try to download the image from [this website](https://fwupd.org/lvfs/devicelist) and install it through "Software" (simply open the file).) Then:

```bash
sudo cp Downloads/Latitude_7x80_1.4.6.exe /boot/efi # Not mv because of permissions
rm Downloads/Latitude_7x80_1.4.6.exe
```

Reboot, hit F12 to initiate the update. Once done, reboot and press F2 to enter BIOS setup. Set a password for the BIOS and the hard drive. [If you want to disable Bluetooth, Advanced > Devices > Onboard](https://www.dell.com/community/Inspiron/Disabling-Bluetooth-from-BIOS/td-p/8069806). Don't forget to remove the file from `/boot/efi` on the next boot.

## Script to switch sound to HDMI when connecting

```bash
sudo su
echo 'KERNEL=="card1", SUBSYSTEM=="drm", ACTION=="change", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/romain/.Xauthority", RUN+="/home/romain/git/dotfiles/scripts/hdmi_sound_toggle.sh"' > /etc/udev/rules.d/99-hdmi_sound.rules
exit
# You might need to swap `card1` with `card0`. Check what card you have:
ls /dev/dri/
# or
ls /run/udev/data/ | grep card

# Now:
sudo udevadm control --reload-rules # Reload rules to take ours into account
sudo udevadm trigger # Tells udev to re-process existing devices and generate events for them
# As a result, check that `/tmp/debug_xrandr`  exists
cat /tmp/debug_xrandr
sudo systemctl restart udev # Not sure this is needed
systemctl daemon-reload # Not sure this is needed
# Debug with `udevadm monitor --environment`
```

## Misc

```bash
sudo apt install acpid
sudo mkdir -p /etc/acpi
sudo cp "$REPO_DIR/etc/acpi/headset.sh" /etc/acpi
sudo cp "$REPO_DIR/etc/acpi/events/headset" /etc/acpi/events
sudo systemctl restart acpid.service

# Install Github CLI
update-gh
```

## Edit terminal preferences

- In `General`, unlimited scrollback. Disable the scrollbar being shown (`Scrollbar is: Disabled`).
- In `Appearance`, uncheck menu bar and borders around new windows. Set the font size to 13.
- In `Colors`, use the `Xubuntu dark` theme, check `Cursor color` and leave the default one.

## Set up Vim

Just open Vim once and let Vim-Plug install all of the listed plugins. Ignore the errors the first time you open Vim, it's because plugins are not yet install. Relaunch it again after, the errors should not appear this time.

## All settings

On the desktop, right click, "Desktop Settings". In the tab "Icons", hide the Home folder icon.

Open the settings manager and do:

- Click _Additional Drivers_ to make sure all devices are being used.
- Set the keyboard layout to US international with dead keys.
- Set up the xfce panel (top bar): show the battery indicator with percent and time remaining (if on a laptop), set the date, time and timezone (clock format: `%a %d %b %T %p`), sync the time with the Internet. Add, from left to right: CPU, Network and System Load monitors.
- In `Window Manager` > `Keyboard`, set the keyboard shortcuts (_Tile window to the x_, _Show desktop_).
- In `Screensaver`:

  - In the tab "Screensaver", enable the screensaver. Pick the "Blank Screen" option, and changes its settings to 5 seconds for "After blanking, put display to sleep after" and "Never" for "After sleeping, switch display off after". Active the screensaver when computer is idle after 1 minutes. Check "Inhibit screensaver for fullscreen applications".
  - In the tab "Lock Screen", enable everything except "On Screen Keyboard" and "Logout".

- In `Display`, in the tab `Advanced`, create a profile for when connected to a TV for instance, and disable `Automatically enable profiles when new display is connected` (handled by `scripts/hdmi_sound_toggle.sh`)
- In `Keyboard` > `Behavior`, enable `Restore num lock state on startup`. Set the repeat delay to 350ms and the repeat speed to 35.
- In `Keyboard` > `Application Shortcuts`, set:

  - Super A: `/home/romain/git/dotfiles/scripts/passmenu`
  - Super C: `google-chrome` / `chromium`
  - Shift Alt 4: `xfce4-screenshooter -r`
  - Ctrl Shift Alt 4: `xfce4-screenshooter -c -r`
  - Ctrl Q: `true`
  - Email client to `Super + M` (should be there by default)
  - Browser to `Super + W` (should be there by default)
  - File explorer to `Super + F` (should be there by default)
  - Super + T: `xfce4-terminal --default-working-directory=/some/path`
  - Super + S: `slack`
  - Ctrl F9: `/home/romain/git/dotfiles/scripts/copy-no-break-line.sh`
  - Ctrl F12: `/home/romain/git/dotfiles/scripts/mprisctl.sh play-pause`
  - F8: `/home/romain/git/dotfiles/scripts/toggle_sound_sinks.sh`
  - F9: `/home/romain/git/dotfiles/scripts/hdmi_sound_toggle.sh`

- In `Power manager`:

  - In the tab "General": disable all switch buttons ("Handle display brightness keys" and all under "Appearance"), set "Do nothing" everywhere except for "When power button is pressed", pick "Ask".
  - In the tab "System", for both "On battery" and "Plugged in", make sure nothing happens when you close the lid, just switch off display. Set the suspend mode to "Never". Critical battery power level on 3% should suspend. Make sure to tick "Lock screen when system is going to sleep".
  - In the tab "Display", for both "On battery" and "Plugged in", "Blank after" never, "Put to sleep after" never, and "Switch off after" never. "Reduce brightness after" never. Yet, **leave "Display power management" on, as otherwise the screensaver won't be able to turn off the screen.**

- In `Removable Drives and Media`, uncheck the 3 options about auto-mount and auto-browse.
- In `Notifications`, log all notifications but not applications.
- In `Mouse and Touchpad`, set the duration for `Disable touchpad while typing` to 0.4s. Also enable horizontal scrolling and `Tap touchpad to click`.

## Fine tune PulseAudio (for Ubuntu older than 24.04. Since 24.04, Pipewire is the default audio server, replacing Pulseaudio)

In `/etc/pulse/default.pa`, disable changing the source to the Dell docking station:

```text
.ifexists module-switch-on-connect.so
load-module module-switch-on-connect blacklist="Dell"
.endif
```

Automatically switch between HiFi bluetooth and bluetooth with microphone:

```text
.ifexists module-bluetooth-policy.so
load-module module-bluetooth-policy auto_switch=2
.endif

```

## Fine tune Pipewire

Automatically switching between HiFi bluetooth and bluetooth with microphone is natively done.

However, we might still need to blacklist some devices. In my tests, this is not needed. But here is how to do it anyways. TODO for myself: delete this section in a few years if this is truly not needed.

```bash
wpctl status # Identify which audio sink and source you want disabled
wpctl inspect <their ID> # Identify their `node.name`

mkdir -p ~/.config/wireplumber/policy.lua.d
touch ~/.config/wireplumber/policy.lua.d/51-blacklist-devices.lua

# Insert the following
monitor.alsa.rules = [
  {
    matches = [
        { "node.name" = "alsa_output.usb-DisplayLink_Dell_Universal_Dock_D6000_1903040272-02.analog-stereo" },
        { "node.name" = "alsa_input.usb-DisplayLink_Dell_Universal_Dock_D6000_1903040272-02.iec958-stereo" }
    ]
    actions = {
      update-props = {
         device.disabled = true
      }
    }
  }
]

# Restart the service
systemctl --user restart wireplumber
```

## Disabling Bluetooth on startup (optional)

In #1 we saw how to hardware disable it. Here we have a look at software disabling it.

Untick Blueman Applet from Settings Manager > Session and Startup > Application Autostart, cause it turns bluetooth on when starting. To check the status, run one of the following commands:

    - `hcitool dev`
    - `rfkill list`
    - `bluetooth`

You can always re-enable bluetooth through the icon in the systray.

To permanently disable bluetooth, and have it not even shown in the systray, do: `sudo systemctl disable bluetooth`

## Fuzzy finder

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --no-update-rc
# Do you want to enable fuzzy auto-completion? No, as its already done in our .rc file
# Do you want to enable key bindings? Yes
```

## Hardening security and checking for malwares

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

## Allow PDF edition

In `/etc/ImageMagick-6/policy.xml`, comment out the last 6 lines:

```xml
<!-- <policy domain="coder" rights="none" pattern="PS" />
<policy domain="coder" rights="none" pattern="PS2" />
<policy domain="coder" rights="none" pattern="PS3" />
<policy domain="coder" rights="none" pattern="EPS" />
<policy domain="coder" rights="none" pattern="PDF" />
<policy domain="coder" rights="none" pattern="XPS" /> -->
```

And increase this line to 8GiB:

```xml
<policy domain="resource" name="disk" value="8GiB"/>
```

## [Enable fingerprint login](https://askubuntu.com/questions/1393550/enabling-fingerprint-login-in-xubuntu)

If your device is compatible (run `lsusb` and compare with [this list](https://fprint.freedesktop.org/supported-devices.html)), then:

```bash
sudo apt install fprintd libpam-fprintd
fprintd-enroll $USER
fprintd-verify $USER
```

Edit `/etc/pam.d/common-auth` and insert `auth sufficient pam_fprintd.so` at the top, like this:

```txt
auth sufficient pam_fprintd.so
auth    [success=1 default=ignore]      pam_unix.so nullok
```

## Optional stuff

### Install [rbenv](https://github.com/rbenv/rbenv?tab=readme-ov-file#basic-git-checkout) (only personal laptop)

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
# Now open a new terminal, we already have the configuration to load rbenv in our file `.rc`
# If the configuration is missing somehow, run: ~/.rbenv/bin/rbenv init
# Then:
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install
# You might need to `sudo apt install libyaml-dev libffi-dev` to compile Ruby
rbenv rehash
gem install bundler
```

### Battery saver (https://doc.ubuntu-fr.org/tlp) - only on Thinkpads!

```bash
sudo apt install tlp
sudo systemctl enable tlp
```

`sudo vim /etc/tlp.conf`:

```txt
START_CHARGE_THRESH_BAT0=55
STOP_CHARGE_THRESH_BAT0=90
```

```bash
sudo tlp start
sudo tlp-stat
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
