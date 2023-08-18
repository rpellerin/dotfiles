#!/bin/sh

echo "Make sure imagemagick is installed."

dirr=`mktemp -d`
echo "Output files will be put in $dirr."

echo "A4 format is 210x297mm."
echo "For best results, we will set the format of the PDF to A4."
echo "It means that your source pictures will be resized to either 1050x1485 pixels or another multiple of that."
echo "What size do you want (bigger = better quality)?"
echo "  1. 1050x1485 (default)"
echo "  2. 2100x2970"
read -r choice

if [ "$choice" = "2" ]; then
    echo "You chose $choice."
    density=100
    page="2100x2970"
    size_x=2100
    size_y=2970
    crop_x=64
else
    echo "You chose 1."
    density=50
    #density=127 # marche pas
    page="1050x1485"
    size_x=1050
    size_y=1485
    crop_x=32
fi


files=""
echo "Now paste all the file paths to concatenate into a PDF file, one by line. Hit enter twice to finish."
echo "Paste here filepaths, one per line."

while read -r file
do
    if [ -z "$file" ]; then xdg-open $dirr; break; fi
    b_name=`basename "$file"`
    convert "$file" -resize x${size_y} "$dirr/$b_name"
    mogrify -crop ${size_x}x+${crop_x}+0 "$dirr/$b_name"
    echo "Next."
done <&0

find "$dirr/" -type f -exec exiftool -all= -TagsFromFile @ -ColorSpaceTags -Orientation '{}' \;
find "$dirr/" -type f -iname "*_original" -exec rm -f '{}' \;
convert "$dirr/*.jpg" -density $density -units pixelspercentimeter "$dirr/output.pdf"
sync
echo "Done."
