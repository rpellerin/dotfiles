# dotfiles

Here are all my favorite dotfiles, taken from my Xubuntu 14.04.

## How do I use your files?
1. `cd $HOME`
2. `mkdir -p git`
3. `cd git/`
4. `git clone https://github.com/rpellerin/dotfiles.git dotfiles`
5. `echo ". ~/git/dotfiles/.rc" >> ~/.zshrc` # Or .bashrc
6. `echo ". ~/git/dotfiles/.aliases" >> ~/.zshrc` # Or .bashrc
7. `ln -s ~/git/dotfiles/.tmux.conf ~/`
8. `ln -s ~/git/dotfiles/.zpreztorc ~/`
9. `ln -s ~/git/dotfiles/.zprezto/modules/tmux/init.zsh ~/.zprezto/modules/tmux/`

I also added a few handy scripts in /scripts/.