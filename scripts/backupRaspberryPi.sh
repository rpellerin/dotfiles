#!/bin/sh

# BACKUP SPECIFIC FILES/DIRECTORIES
# Author: Romain PELLERIN <contact@romainpellerin.eu>
#
# REQUIREMENTS
# tar, gzip
#
# ARGUMENT TO PASS
# 1- The file containing all the files and directories you want to backup
# Example: ./backupRaspberryPi.sh /home/pi/my_list.txt
#
# The list must be something like
# -------------------------------
# /etc/apache2
# /var/www
# -------------------------------

DEST_FILE="/tmp/backup`date --rfc-3339=date`.tar.gz"

FILES_LIST=$1

if [ -z "$FILES_LIST" ]; then
  echo "File containing the list of files to backup (e.g. /home/pi/list.txt)? "
  read FILES_LIST
fi

if [ -z "$FILES_LIST" ] || [ ! -f $FILES_LIST ]; then
  echo "[ERROR]: The list file does not exist: $FILES_LIST"
  exit
fi

echo "Backup started..."

rm -rf /tmp/backup
mkdir -p /tmp/backup

while read DIR; do
  echo $DIR
  cp --parents --preserve=all -r $DIR /tmp/backup
done <"$FILES_LIST"

CURRENT_DIR="`pwd`"
cd /tmp && tar --preserve-permissions -zcf $DEST_FILE backup && rm -rf /tmp/backup && echo "\n$DEST_FILE created" || echo "\nAn error occured"
cd $CURRENT_DIR