#!/bin/sh
TMP_DIR=$(mktemp -d)
cd $TMP_DIR
sudo wget "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" -O $TMP_DIR/firefox-nightly.tar.bz2
sudo tar -xjf firefox-nightly.tar.bz2
sudo rm -rf /opt/firefox-nightly
sudo mv firefox /opt/firefox-nightly
echo "Firefox Nightly has just been upgraded."
