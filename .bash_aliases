#############
# FUNCTIONS #
#############

# Backup a file with date
function backup() {
    cp "$1" "$1_`date +%Y-%m-%d_%H-%M-%S`_BACKUP"
}

# Extract any archive
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)  tar xjf $1      ;;
            *.tar.gz)   tar xzf $1      ;;
            *.bz2)      bunzip2 $1      ;;
            *.rar)      rar x $1        ;;
            *.gz)       gunzip $1       ;;
            *.tar)      tar xf $1       ;;
            *.tbz2)     tar xjf $1      ;;
            *.tgz)      tar xzf $1      ;;
            *.zip)      unzip $1        ;;
            *.Z)        uncompress $1   ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Ban an IP
function ban() {
    if [ "`id -u`" == "0" ] ; then
        iptables -A INPUT -s $1 -j DROP
    else
        sudo iptables -A INPUT -s $1 -j DROP
    fi
}

# Update + upgrade the system
function maj() {
    sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude autoclean && sudo aptitude clean
    notify-send -t 10000 "Update and upgrade done"
}

# Display the content of a directory after a 'cd'
function custom_cd () {
        cd $@ && ls
}

# Open a file with the appropriate application
function open {
    while [ "$1" ] ; do
        xdg-open $1 &> /dev/null
        shift # shift décale les param
    done
}

# Remove all backup files in specified directory and sub-directories
function rm_backup {
    find $1 -name '*~' -exec rm '{}' \; -print
}

# A reminder
function find? {
    echo "--------------------------------------------------------"
    echo "Delete a file recursively:"
    echo "find / -name '*.DS_Store' -type f -delete"
    echo "--------------------------------------------------------"
    echo "Rename a file recursively:"
    echo "find / -type f -exec rename 's/oldname/newname/' '{}' \;"
    echo "--------------------------------------------------------"
    echo "Find recently modified files"
    echo "find / -type f -printf '%TY-%Tm-%Td %TT %p\n' | sort -r"
    echo "--------------------------------------------------------"
}

# A reminder
function git? {
    echo "-------------------------------------------------------------------------------"
    echo "git clone http://... [repo-name]"
    echo "git init [repo-name]"
    echo "-------------------------------------------------------------------------------"
    echo "git add -A <==> git add . ; git add -u" # Add to the staging area (index)
    echo "-------------------------------------------------------------------------------"
    echo "git commit -m 'message' -a"
    echo "git commit -m 'message' -a --amend"
    echo "-------------------------------------------------------------------------------"
    echo "git status"
    echo "git log --stat" # Last commits, --stat optional
    echo "git ls-files"
    echo "-------------------------------------------------------------------------------"
    echo "git push origin master"
    echo "git push origin master:master"
    echo "-------------------------------------------------------------------------------"
    echo "git remote add origin http://..."
    echo "git remote set-url origin git://..."
    echo "-------------------------------------------------------------------------------"
    echo "git pull origin master"
    echo "-------------------------------------------------------------------------------"
    echo "git submodule add /absolute/path repo-name"
    echo "git submodule add http://... repo-name"
    echo "-------------------------------------------------------------------------------"
    echo "git checkout -b new-branch <==> git branch new-branch ; git checkout new-branch"
    echo "git merge old-branch"
    echo "-------------------------------------------------------------------------------"
    echo "git update-index --assume-unchanged <file>" # Ignore changes
    echo "git rm --cached <file>" # Untrack a file
    echo "-------------------------------------------------------------------------------"

}


#########
# ALIAS #
#########

# Overriding default commands
alias ls='ls --color=auto'
alias grep='grep -i --color=auto'
alias rm='rm --interactive --verbose'
alias mv='mv --interactive --verbose'
alias cp='cp --verbose'
alias cd="custom_cd" # custom_cd is a custom function (see above)

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Handy shortcuts
alias q='exit'
alias lstree="find . | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'"
alias path='echo $PATH | tr ":" "\n"'
alias watch='watch ' # Source of this hack: http://yabfog.com/blog/2012/09/06/using-watch-with-a-bash-alias
alias ssh='ssh -X'
alias sshpi="ssh pi@serveur"

# Some sources : 
#  - http://root.abl.es/methods/1504/automatic-unzipuntar-using-correct-tool/
#  - http://forum.ubuntu-fr.org/viewtopic.php?id=20437&p=3
#  - http://www.mercereau.info/partage-de-mon-fichier-bash_aliases/
