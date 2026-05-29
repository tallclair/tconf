#!/bin/bash

UPSTREAM="$(git config --get remote.upstream.url)"
if [[ $? == 0 ]]; then
  >&2 echo "Upstream already found: $UPSTREAM"
  exit 1
fi

ORIGIN="$(git config --get remote.origin.url)"
if [[ $? != 0 ]]; then
  >&2 echo "Origin not found"
  exit 1
fi

if [[ ! $ORIGIN =~ github.com ]]; then
  >2& echo "Only github.com origins supported. Found: $ORIGIN"
  exit 1
fi

# Parse origin pieces
case "$ORIGIN" in
  https://github.com/*)
    GH_PATH="${ORIGIN#https://github.com/}"
    ;;
  git@github.com:*)
    GH_PATH="${ORIGIN#git@github.com:}"
    ;;
  *)
    >2& echo "Unknown origin format: $ORIGIN"
    exit 1
    ;;
esac

ORG="${GH_PATH%/*}"
REPO="${GH_PATH#*/}"
REPO="${REPO%.git}"

if [[ -z $ORG ]]; then
  >2& echo "Failed to parse ORG: $ORIGIN"
  exit 1
fi
if [[ -z $REPO ]]; then
  >2& echo "Failed to parse REPO: $ORIGIN"
  exit 1
fi

DST_ORG="$(git config --get user.github || echo $USER)"
DST_REPO="$REPO"

if [[ $# == 1 ]]; then
  DST_REPO="$1"
elif [[ $# == 2 ]]; then
  DST_ORG="$1"
  DST_REPO="$2"
fi

# Move origin to upstream
git remote rename origin upstream

# Prevent pushing to upstream
git remote set-url --push upstream nopush

# Add origin
git remote add origin "git@github.com:${DST_ORG}/${DST_REPO}.git"
git fetch origin
