#!/bin/bash -e

dirr=`mktemp -d`
echo "Output files will be put in $dirr."

echo "The current directory will be processed: $(pwd)"
echo "Continue? (any key will continue, ^C to exit)"
read -r continuing
echo "Processing..."
# ${f#*.} retrieved the extension from the variable $f
ls | cat -n | while read n f; do cp -n "$f" "$dirr/$(printf "%05d.${f#*.}" $n)"; done
xdg-open "$dirr"
echo "Done"
echo "Syncing..."
sync
echo "Synced"
