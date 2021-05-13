#!/bin/bash

xsel --clipboard | tr '\n' ' ' | xclip -i -selection clip-board
