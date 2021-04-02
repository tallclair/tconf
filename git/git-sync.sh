#!/bin/sh -e

REMOTE=${1:-upstream}
BRANCH=${2:-}

git fetch $REMOTE

if [[ -z "$BRANCH" ]]; then
    if [[ ! -z "$(git branch -r --list ${REMOTE}/master)" ]]; then
        BRANCH=master
    elif [[ ! -z "$(git branch -r --list ${REMOTE}/main)" ]]; then
        BRANCH=main
    else
        >&2 echo "cannot determine default branch"
        exit 1
    fi
fi

git rebase $REMOTE/$BRANCH
