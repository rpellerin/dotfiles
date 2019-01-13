#!/bin/bash

for var in "$@"
do
    /usr/bin/xdg-open "$var"
done
