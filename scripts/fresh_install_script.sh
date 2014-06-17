#!/bin/bash

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

install() {
    while true; do
        read -p "Do you wish to install $1? " yn
        case $yn in
            [Yy]* ) sudo aptitude install $1; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# https://github.com/sorin-ionescu/prezto
install_prezto() {
    rm -rf "$HOME/.zprezto"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
    ln -sf $HOME/.zprezto/runcoms/zlogin $HOME/.zlogin
    ln -sf $HOME/.zprezto/runcoms/zlogout $HOME/.zlogout
    ln -sf $HOME/.zprezto/runcoms/zpreztorc $HOME/.zpreztorc
    ln -sf $HOME/.zprezto/runcoms/zprofile $HOME/.zprofile
    ln -sf $HOME/.zprezto/runcoms/zshenv $HOME/.zshenv
    ln -sf $HOME/.zprezto/runcoms/zshrc $HOME/.zshrc
}

############################## BEGINNING OF THE SCRIPT ##############################

while true; do
    read -p "Do you wish to update and upgrade your system? " yn
    case $yn in
        [Yy]* ) sudo aptitude update ; sudo aptitude upgrade; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

install git
install zsh

command -v zsh >/dev/null && {
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
    read -p "Do you wish to install prezto? " yn
    case $yn in
        [Yy]* ) install_prezto; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

install tmux
install imagemagick # Manipulating images

echo "All done! Enjoy your ULTIMATE Linux distro ;)"