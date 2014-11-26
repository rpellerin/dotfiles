#!/bin/sh

# UPDATE YOUTUBE-DL FROM GITHUB
# Author: Romain PELLERIN <contact@romainpellerin.eu>
# Inspired from: http://www.raspberrypi.org/forums/viewtopic.php?f=38&t=83763
#
# REQUIREMENTS
# git
#
# ARGUMENT TO PASS
# 1- The directory that contains the git repo of youtueb-dl
# Example: ./updateYoutubeDl.sh /home/pi/git/youtube-dl

GIT_REPO=$1
CURRENT_DIR="`pwd`"
file=__main__.py
maxsize=1000

if [ -z "$GIT_REPO" ]; then
  echo "Where is the Git repo (e.g. /home/pi/git/youtube-dl)? "
  read GIT_REPO
fi

if [ -z "$GIT_REPO" ] || [ ! -d $GIT_REPO ]; then
  echo "[ERROR]: The directory does not exist: $GIT_REPO"
  exit
fi

echo "Update started..."


cd $GIT_REPO
git pull origin master
cd youtube_dl
actualsize=$(wc -c "$file" | cut -f 1 -d ' ')
if [ $actualsize -ge $maxsize ]
then
  wget -O __main__.py https://raw.githubusercontent.com/rg3/youtube-dl/master/youtube_dl/__main__.py
  chmod +x __main__.py
  echo "main updated"
else
  echo "main file ok"
fi

echo "YOUTUBE-DL UPDATED SUCCESSFULLY"
cd "$CURRENT_DIR"