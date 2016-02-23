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

############################## BEGINNING OF THE SCRIPT ##############################

echo "You should install https://github.com/tmux-plugins/tmux-battery"

while true; do
    read -p "Do you wish to use the dotfiles from this git repo? " yn
    case $yn in
        [Yy]* ) copy_dotfiles; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done