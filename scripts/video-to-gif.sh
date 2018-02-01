#!/bin/sh

# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html

if [ "$#" -lt 2 ]; then
    echo "Illegal usage. First parameter must be the source video and second parameter must be the output GIF. Third parameter (optional) must be the gif width."
    exit
fi

size=$3

if [ "$#" -ne 3 ]; then
    size=$(ffprobe -v quiet -print_format json -show_streams $1 | grep -Po '"width": \K(\d+)')
fi

echo "Output file GIF will be $size pixel wide"

palette="/tmp/palette.png"

filters="fps=15,scale=$size:-1:flags=lanczos"

ffmpeg -v warning -i $1 -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $1 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $2
