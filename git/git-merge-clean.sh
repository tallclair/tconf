#!/bin/bash

set -euf

UPSTREAM="${UPSTREAM:-upstream}"
WORKING_BRANCH="$(git current-branch)"

if [[ ! -z "$(git branch -r --list ${UPSTREAM}/master)" ]]; then
    MAIN_BRANCH=master
elif [[ ! -z "$(git branch -r --list ${UPSTREAM}/main)" ]]; then
    MAIN_BRANCH=main
else
    >&2 echo "cannot determine main branch"
    exit 1
fi

git fetch "${UPSTREAM}"

git checkout -B ${MAIN_BRANCH} "${UPSTREAM}/${MAIN_BRANCH}"
sleep 1

# Delete merged branches, exclude current branch, master/main, and dev.
git branch --merged "${UPSTREAM}/${MAIN_BRANCH}" | grep -v '\*' | grep -v "${WORKING_BRANCH}" | grep -v master | grep -v main | grep -v dev | xargs -r -n1 git branch -d
sleep 1

# Special case cherry-picks
for rel in $(git branch -r -l "${UPSTREAM}/release-*" | grep -E "/release-1.[1-9][0-9]$"); do
  git checkout -B $(basename "$rel") "$rel"
  sleep 1
  git branch --merged "$rel" | grep -v '\*' | grep -v $(basename "$rel") | xargs -r -n1 git branch -d
  sleep 1
done

git checkout "$WORKING_BRANCH"
