#!/bin/bash
while IFS='' read -r line || [[ -n "$line" ]]; do
    SITE=$(echo "$line" | awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{print $1}')
    LOGIN=$(echo "$line" | awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{print $3}')
    PASSWORD=$(echo "$line" | awk -vFPAT='([^,]*)|("[^"]+")' -vOFS=, '{print $4}' | sed -e 's/^"//g' -e 's/"$//g' -e 's/""/"/g')
    echo "$PASSWORD" | pass insert -m "$SITE/$LOGIN"
done < "$1"
