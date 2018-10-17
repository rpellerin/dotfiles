#!/bin/bash

echo 'Total file number'
git ls-files | grep -E '\.rb$|\.js$|\.scss$' | wc -l

echo 'Your file number'
git log --no-merges --author="Pellerin" --name-only --pretty=format:"" | sort -u | while IFS= read -r f; do [[ -f "$f" ]] && echo "$f"; done | grep -E '\.rb$|\.js$|\.scss$' | wc -l