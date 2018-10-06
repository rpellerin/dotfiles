#!/bin/bash -e

# The input file must be like:
# website1/username password
# website2/username password
# ....

COUNT=0
TOTAL_LINES=$(wc -l "$1" | cut -d ' ' -f1)

while IFS='' read -r line || [[ -n "$line" ]]; do
    COUNT=$((COUNT+1))
    SITE_LOGIN=$(echo "$line" | cut -d ' ' -f1)
    PWD=$(echo "$line" | cut -d ' ' -f2)
    echo "$COUNT/$TOTAL_LINES"
    echo $SITE_LOGIN...
    echo "$PWD" | pass insert --multiline "$SITE_LOGIN"
    echo 'Done.'
    echo ''
done < "$1"
