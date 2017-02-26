#!/bin/sh

# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html

if [ "$#" -ne 3 ]; then
    echo "Illegal usage. First parameter must be the gif width, second must be the source video and third parameter must be the output GIF"
    exit
fi

palette="/tmp/palette.png"

filters="fps=15,scale=$1:-1:flags=lanczos"

ffmpeg -v warning -i $2 -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $2 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $3
