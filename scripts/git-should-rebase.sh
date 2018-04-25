#!/bin/sh

# Taken from https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

# Assumes you've run `git fetch` or `git remote update` beforehand.

RED_COLOR='\033[0;31m'
RESET_STYLES='\033[0m'
BOLD='\033[1m'

UPSTREAM='origin/master'
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    exit 0
    #echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
    echo "${RED_COLOR}${BOLD}Need to pull.${RESET_STYLES}"
elif [ $REMOTE = $BASE ]; then
    exit 0
    #echo "Need to push"
else
    echo "${RED_COLOR}${BOLD}Rebase on $UPSTREAM available.${RESET_STYLES}"
fi
