#!/bin/sh

matches=$(git diff --cached | grep -E '\+.*?FIXME')

if [ "$matches" != "" ]
then
        echo "'FIXME' tag is detected."
        echo "Please fix it before committing."
        echo "  ${matches}"
        exit 1
fi
