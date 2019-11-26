#!/bin/sh

# Resize an image to 700px width, keeping the ratio

echo "Make sure imagemagick is installed."

dirr=`mktemp -d`
echo "Output files will be put in $dirr"
echo "Resizing to $size pixel wide..."
echo "Paste here filepaths, one per line."

size=$1

if [ "$#" -ne 1 ];then
    size=700
fi

while read -r file
do
    if [ -z "$file" ]; then xdg-open $dirr; break; fi
    b_name=`basename "$file"`
    convert "$file" -resize $size "$dirr/$b_name"
    echo "Next."
done <&0

exiftool -all= "$dirr/*"
rm -f "$dirr/*_original"
echo "Done."
