#!/bin/sh

# BACKUP APACHE CONFIGURATION AND WEBSITES
# Author: Romain PELLERIN <contact@romainpellerin.eu>
#
# REQUIREMENTS
# tar, gzip
#
# ARGUMENT TO PASS
# 1- The Apache installation directory
# 2- The websites directory
# Example: ./backupApache.sh /etc/apache /var/www

DEST_FILE="apache_backup`date --rfc-3339=date`.tar.gz"

APACHE_DIR=$1
WEBSITES_DIR=$2

if [ -z "$APACHE_DIR" ]; then
  echo "Apache installation directory full path (e.g. /etc/apache2)? "
  read APACHE_DIR
fi

if [ -z "$APACHE_DIR" ] || [ ! -d $APACHE_DIR ]; then
  echo "[ERROR]: Apache installation directory does not exist: $APACHE_DIR"
  exit
fi

if [ -z "$WEBSITES_DIR" ]; then
  echo "Websites directory full path (e.g. /var/www)? "
  read WEBSITES_DIR
fi

if [ -z "$WEBSITES_DIR" ] || [ ! -d $WEBSITES_DIR ]; then
  echo "[ERROR]: Websites directory does not exist: $WEBSITES_DIR"
  exit
fi

echo "Backup started..."

mkdir -p /tmp/apache_backup

mkdir -p /tmp/apache_backup/apache
cd $APACHE_DIR
cp --preserve=all -r -L apache2.conf envvars ports.conf conf* mods-enabled sites-available sites-enabled /tmp/apache_backup/apache

mkdir -p /tmp/apache_backup/websites
cd $WEBSITES_DIR
cp --preserve=all -r -L . /tmp/apache_backup/websites

cd /tmp && tar --preserve-order --preserve-permissions -zcf $DEST_FILE apache_backup && rm -rf apache_backup && echo "\n\n/tmp/$DEST_FILE created" || echo "\n\nAn error occured"