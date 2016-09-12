#!/bin/sh

# Resize an image to 700px width, keeping the ratio

echo "Make sure imagemagick is installed."

dirr=`mktemp -d`
echo "Output files will be put in $dirr"
echo "Paste here filepaths, one per line."

while read -r file
do
    if [ -z "$file" ]; then xdg-open $dirr; exit; fi
    b_name=`basename "$file"`
    convert "$file" -resize 700 "$dirr/$b_name"
    echo "Next."
done <&0
