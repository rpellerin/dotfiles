# https://github.com/sorin-ionescu/prezto
install_prezto() {
    rm -rf "$HOME/.zprezto" && echo "Old install deleted"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto" && {
        ln -sf $HOME/.zprezto/runcoms/zlogin $HOME/.zlogin
        ln -sf $HOME/.zprezto/runcoms/zlogout $HOME/.zlogout
        ln -sf $HOME/.zprezto/runcoms/zpreztorc $HOME/.zpreztorc
        ln -sf $HOME/.zprezto/runcoms/zprofile $HOME/.zprofile
        ln -sf $HOME/.zprezto/runcoms/zshenv $HOME/.zshenv
        ln -sf $HOME/.zprezto/runcoms/zshrc $HOME/.zshrc
    }
}

install_pandoc() {
    sudo aptitude install haskell-platform
    cabal update
    cabal install pandoc
    cabal install pandoc-citeproc
}

install_teamviewer() {
    wget http://download.teamviewer.com/download/teamviewer_linux.deb -O /tmp/teamviewer.deb && sudo dpkg -i /tmp/teamviewer.deb
    sudo apt-get -f install
    rm /tmp/teamviewer.deb -f
}

install_eg() {
    git clone https://github.com/srsudar/eg $HOME/.eg && sudo ln -fs $HOME/.eg/eg_exec.py /usr/local/bin/eg
}

copy_dotfiles() {
    grep ". $REPO_DIR/.rc" $HOME/.zshrc >/dev/null || {
        echo ". $REPO_DIR/.rc" >> $HOME/.zshrc && echo ".rc added to $HOME/.zshrc"
    }
    grep ". $REPO_DIR/.aliases" $HOME/.zshrc >/dev/null || {
        echo ". $REPO_DIR/.aliases" >> $HOME/.zshrc && echo ".aliases added to $HOME/.zshrc"
    }
    ln -sf $REPO_DIR/.tmux.conf $HOME/ && echo ".tmux.conf copied (symlink)"
    ln -sf -s $REPO_DIR/.zpreztorc $HOME/ && echo ".zpreztorc copied (symlink)"
    ln -sf -s $REPO_DIR/.curlrc $HOME/ && echo ".curlrc copied (symlink)"
    mkdir -p $HOME/.config/sublime-text-3/Packages/User && echo "$HOME/.config/sublime-text-3/Packages/User created"
    ln -sf $REPO_DIR/.config/sublime-text-3/Packages/User/* $HOME/.config/sublime-text-3/Packages/User && {
      echo "-- Some files has been copied in the last created directory (symlinks)"
    }
    mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml && echo "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml created"
    ln -sf $REPO_DIR/.config/xfce4/xfconf/xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/ && {
      echo "-- Some files has been copied in the last created directory (symlinks)"
    }
    mkdir -p $HOME/.config/xfce4/panel && echo "$HOME/.config/xfce4/panel created"
    ln -sf $REPO_DIR/.config/xfce4/panel/* $HOME/.config/xfce4/panel/ && {
      echo "-- Some files has been copied in the last created directory (symlinks)"
    }
    ln -sf "$REPO_DIR/.gitconfig" $HOME/ && echo ".gitconfig copied (symlink)"
    cp -i "$REPO_DIR/Images/pause.png" $HOME/Images/pause.png && echo "Images/pause.png copied (true copy)"
    echo "Done"
}

install_firewall() {
    sudo cp -i $REPO_DIR/scripts/firewall.sh /etc/init.d/ && sudo chmod 700 /etc/init.d/firewall.sh && sudo chown root:root /etc/init.d/firewall.sh && sudo update-rc.d firewall.sh defaults && echo "Firewall installed"
}

install_fix_brightness() {
    sudo touch /etc/init.d/prev_brightness
    sudo chmod 600 /etc/init.d/prev_brightness
    sudo rm /etc/init.d/save_screen_brightness -f
    sudo touch /etc/init.d/save_screen_brightness
    sudo chmod 700 /etc/init.d/save_screen_brightness
    sudo sh -c "echo '#\!/bin/sh' >> /etc/init.d/save_screen_brightness"
    sudo sh -c "echo 'cat /sys/class/backlight/acpi_video0/brightness > /etc/init.d/prev_brightness' >> /etc/init.d/save_screen_brightness"
    sudo ln -sf /etc/init.d/save_screen_brightness /etc/rc0.d/K99save_screen_brightness
    sudo ln -sf /etc/init.d/save_screen_brightness /etc/rc6.d/K99save_screen_brightness
    sudo grep "cat /etc/init.d/prev_brightness > /sys/class/backlight/acpi_video0/brightness" /etc/rc.local || {
      sudo sed -i 's/^exit 0/cat \/etc\/init.d\/prev_brightness > \/sys\/class\/backlight\/acpi_video0\/brightness\nexit 0/' /etc/rc.local
    }
}

############################## BEGINNING OF THE SCRIPT ##############################

command -v teamviewer >/dev/null || {
    while true; do
        read -p "Do you wish to install TeamViewer ? " yn
        case $yn in
            [Yy]* ) install_teamviewer; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

command -v zsh >/dev/null && {
    while true; do
        read -p "Do you wish to install prezto/clean your current prezto install? " yn
        case $yn in
            [Yy]* ) install_prezto; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

command -v eg >/dev/null && {
while true; do
    read -p "eg gives examples of command. For instance type 'eg tar'. Do you wish to install eg? " yn
    case $yn in
        [Yy]* ) install_eg; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

command -v pandoc >/dev/null || {
    while true; do
        read -p "Do you wish to install Haskell and Pandoc ? " yn
        case $yn in
            [Yy]* ) install_pandoc; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

echo "You should install https://github.com/tmux-plugins/tmux-battery"
install exiftool # EXIF data
install jhead # EXIF data
install optipng # Lossless compression
install biber
install filezilla
install sublime-text
install atom
install cloc
install zenity
install icoutils
install zathura
install wireshark
install htop
install synaptic
install gtk-recordmydesktop
install pdf-presenter-console
install openvpn
install network-manager-openvpn
install network-manager-vpnc
install codeblocks

while true; do
    read -p "Do you wish to use the dotfiles from this git repo? " yn
    case $yn in
        [Yy]* ) copy_dotfiles; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to install the firewall? " yn
    case $yn in
        [Yy]* ) install_firewall; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you use a laptop and is your screen brightness reseted at every reboot? " yn
    case $yn in
        [Yy]* ) install_fix_brightness; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "You shoud install f.lux and launch it at startup (Menu>Settings>Session and startup): http://doc.ubuntu-fr.org/f.lux#installation_manuelle"