#!/bin/sh

# Taken from https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

# Assumes you've run `git fetch` or `git remote update` beforehand.

RED_COLOR='\033[0;31m'
RESET_STYLES='\033[0m'
BOLD='\033[1m'

UPSTREAM='origin/master'

if [ -z "$UPSTREAM" ]; then
    exit 0
fi

# Exits if remote branch does not exists
git branch -a | grep "$UPSTREAM">/dev/null
if [ $? -eq 1 ]; then
    exit 0
fi

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ -z "$BASE" ]; then
    exit 0
fi
if [ $LOCAL = $REMOTE ]; then
    #echo "Up-to-date"
    exit 0
elif [ $LOCAL = $BASE ]; then
    echo "${RED_COLOR}${BOLD}Need to pull.${RESET_STYLES}"
elif [ $REMOTE = $BASE ]; then
    #echo "Need to push"
    exit 0
else
    echo "${RED_COLOR}${BOLD}Rebase on $UPSTREAM available.${RESET_STYLES}"
fi
