#!/bin/sh

# Rotate a video by 180 degrees

echo "Make sure ffmpeg is installed."

dirr=`mktemp -d`
echo "Output files will be put in $dirr"
echo "Paste here filepaths, one per line."

while read -r file
do
    if [ -z "$file" ]; then exit; fi
    b_name=`basename "$file"`
    ffmpeg -i "$file" -c copy -metadata:s:v:0 rotate=0 "$dirr/tmp_$b_name"
    ffmpeg -i "$dirr/tmp_$b_name" -vf "transpose=2,transpose=2,format=yuv420p" -codec:v libx264 -c:a copy "$dirr/$b_name"
    rm "$dirr/tmp_$b_name"
    echo "Next."
done <&0

xdg-open $dirr
