#!/bin/bash

set -e

#yarn upgrade-interactive --latest

DIFF=$(git diff -U0 package.json | grep '^[+-]' | grep -Ev '^(--- |\+\+\+ )')
PACKAGE=$(echo "$DIFF" | awk '{print $2}' | sed 's/[":]//g' | head -n 1)
VERSIONS=$(echo "$DIFF" | awk '{print $3}' | sed 's/[",^]//g')
OLD_VERSION=$(echo "$VERSIONS" | head -n 1)
NEW_VERSION=$(echo "$VERSIONS" | tail -n 1)

COMMIT_MESSAGE="chore(npm): Upgrade $PACKAGE from $OLD_VERSION to $NEW_VERSION"

read -p "$COMMIT_MESSAGE? [y|n] " -r yn < /dev/tty

echo $yn | grep ^[Yy]$ 1>/dev/null

if [ $? -eq 0 ]; then
  git add -A
  git commit -m "$COMMIT_MESSAGE" -m 'UPGRADE-NPM-PACKAGES'
  # git push
  exit 0
fi

exit 1
