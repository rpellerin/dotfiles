#!/bin/sh
export http_proxy=vpn.kyane.fr:8888
cd /transmission-downloads/jimmy-fallon/

url=$(curl -s 'http://www.nbc.com/the-tonight-show/' | grep 'data-type="Home:Content_Episode"' | sed 's/<a href="//;s/".*$//' | tail -n 1)
number=$(echo $url | sed 's/\/the-tonight-show\/episodes\///')
youtube-dl "http://www.nbc.com"$url --no-post-overwrites -w -o "$number.%(ext)s" --no-part

unset http_proxy
