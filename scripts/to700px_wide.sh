#!/bin/sh

# Resize an image to 700px width, keeping the ratio

echo "Make sure imagemagick is installed."

sizes=$@

if [ "$#" -eq 0 ];then
    sizes="700"
fi

dirr=`mktemp -d`
echo "Output files will be put in $dirr"
echo "Resizing to $sizes pixel wide..."
echo "Paste here filepaths, one per line."

while read -r file
do
    if [ -z "$file" ]; then xdg-open $dirr; break; fi

    for size in ${sizes}
    do
        b_name=`basename "$file"`
        convert "$file" -resize ${size}x "$dirr/$size-$b_name"
    done
    echo "Next."
done <&0

find "$dirr/" -type f -exec exiftool -all= -TagsFromFile @ -ColorSpaceTags -Orientation '{}' \;
find "$dirr/" -type f -iname "*_original" -exec rm -f '{}' \;
echo "Done."
