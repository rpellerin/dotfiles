#!/bin/bash

for var in "$@"
do
    echo "Opening $var..."
    /usr/bin/xdg-open "$var"
done
