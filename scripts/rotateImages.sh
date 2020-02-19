#!/bin/sh

echo "Make sure imagemagick is installed."

size=$1

if [ "$#" -ne 1 ];then
    rot=90
fi

dirr=`mktemp -d`
echo "Output files will be put in $dirr"
echo "Rotating by $rot degrees..."
echo "Paste here filepaths, one per line."

while read -r file
do
    if [ -z "$file" ]; then xdg-open $dirr; break; fi
    b_name=`basename "$file"`
    convert "$file" -rotate ${rot} "$dirr/$b_name"
    echo "Next."
done <&0

find "$dirr/" -type f -exec exiftool -all= '{}' \;
find "$dirr/" -type f -iname "*_original" -exec rm -f '{}' \;
echo "Done."
