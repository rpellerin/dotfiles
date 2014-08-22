#!/bin/sh

# HANDY SCRIPT TO RUN AFTER A FRESH INSTALL OF *UBUNTU
# Don't run it with root rights, only with a regular user
# Author: Romain PELLERIN <contact@romainpellerin.eu>
#
# REQUIREMENTS
# None
#
# ARGUMENT TO PASS
# None
# Example: ./fresh_install_script.sh

REPO_DIR=`cd "$( dirname "$0" )/../" && pwd`

install() {
    command -v $1 >/dev/null || {
    while true; do
        read -p "Do you wish to install $1? " yn
        case $yn in
            [Yy]* ) sudo aptitude install $1; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    }
}

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

install_teamviewer() {
    wget http://download.teamviewer.com/download/teamviewer_linux.deb -O /tmp/teamviewer.deb && sudo dpkg -i /tmp/teamviewer.deb
    rm /tmp/teamviewer.deb -f
    sudo apt-get -f install
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

############################## BEGINNING OF THE SCRIPT ##############################

command -v aptitude >/dev/null || while true; do
    read -p "Do you wish to install aptitude (required to continue)? " yn
    case $yn in
        [Yy]* ) sudo apt-get update ; sudo apt-get install aptitude; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to update and upgrade your system? " yn
    case $yn in
        [Yy]* ) sudo aptitude update ; sudo aptitude upgrade; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

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

install zsh

[ $SHELL != "/bin/zsh" ] && command -v zsh >/dev/null && {
    while true; do
        read -p "Do you wish to set zsh as your default shell? " yn
        case $yn in
            [Yy]* ) chsh -s /bin/zsh; break;;
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

install libreoffice

command -v libreoffice >/dev/null && {
while true; do
    read -p "Do you wish to install FR package for libreoffice? " yn
    case $yn in
        [Yy]* ) sudo aptitude install libreoffice-l10n-fr libreoffice-help-fr hyphen-fr; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

install git
install tmux
install imagemagick # Manipulating images
install optipng # Lossless compression
install default-jdk
install texlive-full
install filezilla
install sublime-text
install gcolor2
install zathura
install wireshark
install vlc
install htop
install gigolo
install synaptic
install gtk-recordmydesktop
install gedit
install i3lock
install pdf-presenter-console
install p7zip-full

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

echo "All done! Enjoy your ULTIMATE Linux distro ;)"
