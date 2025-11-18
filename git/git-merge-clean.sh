#!/bin/bash

set -euf

UPSTREAM="${UPSTREAM:-upstream}"
git fetch "${UPSTREAM}"

MAIN_BRANCH="$(git remote show ${UPSTREAM} | sed -n '/HEAD branch/s/.*: //p')"


# Delete merged branches, exclude current branch, master/main, and dev.
FILTER="^[*+]|master|main|dev|release-1.[0-9]*"

clean-branch() {
    BASE="$1"
    echo "Checking $BASE..."
    
    if MERGED=($(git branch --merged "$BASE" | grep -Ev "$FILTER")); then
        echo "Found merged branches: ${MERGED[8]}"
        git branch -d "${MERGED[@]}"
    fi
}

clean-branch "${UPSTREAM}/${MAIN_BRANCH}"

# Special case cherry-picks
while read -r rel_branch; do
  clean-branch $rel_branch
done < <(git branch -r -l "${UPSTREAM}/release-1.[3-9][0-9]")
