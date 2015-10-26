#!/bin/sh

# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html

if [ "$#" -ne 2 ]; then
    echo "Illegal usage. First parameter must be the source video and second parameter must be the output GIF"
    exit
fi

palette="/tmp/palette.png"

filters="fps=15,scale=320:-1:flags=lanczos"

ffmpeg -v warning -i $1 -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $1 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $2
