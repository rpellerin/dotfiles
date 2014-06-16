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

############################## BEGINNING OF THE SCRIPT ##############################

while true; do
    read -p "Do you wish to update and upgrade your system? " yn
    case $yn in
        [Yy]* ) sudo aptitude update ; sudo aptitude upgrade; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

install zsh
command -v zsh && {
while true; do
    read -p "Do you wish to set zsh as your default shell? " yn
    case $yn in
        [Yy]* ) chsh -s /bin/zsh; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}
command -v zsh && {
while true; do
    read -p "Do you wish to install oh_my_zsh? " yn
    case $yn in
        [Yy]* ) wget --no-check-certificate http://install.ohmyz.sh -O - | sh; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

install tmux
install imagemagick # Manipulating images
install git

echo "All done! Enjoy your ULTIMATE Linux distro ;)"