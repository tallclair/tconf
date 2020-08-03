#!/bin/bash

set -euf

UPSTREAM="${UPSTREAM:-upstream}"
WORKING_BRANCH="$(git current-branch)"

git fetch "${UPSTREAM}" master
git checkout -B master "${UPSTREAM}/master"
sleep 1

git branch --merged "${UPSTREAM}/master" | grep -v '\*' | grep -v master | grep -v dev | xargs -r -n1 git branch -d
sleep 1

# Special case cherry-picks
for rel in $(git branch -r -l "${UPSTREAM}/release-*" | grep -E "/release-1.[1-9][0-9]$"); do
  git checkout -B $(basename "$rel") "$rel"
  sleep 1
  git branch --merged "$rel" | grep -v '\*' | grep -v $(basename "$rel") | xargs -r -n1 git branch -d
  sleep 1
done

git checkout "$WORKING_BRANCH"
