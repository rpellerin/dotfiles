#!/bin/sh

# Resize an image to 700px width, keeping the ratio

echo "Make sure imagemagick is installed."

size=$1

if [ "$#" -ne 1 ];then
    size=1485
fi

dirr=`mktemp -d`
echo "Output files will be put in $dirr"
echo "Paste here filepaths, one per line."

while read -r file
do
    if [ -z "$file" ]; then xdg-open $dirr; break; fi
    b_name=`basename "$file"`
    convert "$file" -resize x${size} "$dirr/$b_name"
    mogrify -crop 1050x+32+0 "$dirr/$b_name"
    echo "Next."
done <&0

find "$dirr/" -type f -exec exiftool -all= -TagsFromFile @ -ColorSpaceTags -Orientation '{}' \;
find "$dirr/" -type f -iname "*_original" -exec rm -f '{}' \;
echo "Done."
