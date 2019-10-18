#!/bin/bash

TCONF="${TCONF:=$HOME/tconf}"

. $TCONF/lib/homemaker.sh || exit 1

BASE="$HOME/tconf"
INPUT="$BASE"
OUTPUT="$HOME"
CONFIG="setup.sh"

hm_init

# i3 configuration
hmgl .i3/config "#" {,local/,priv/}i3/{config,win_rules,keys}

# shell configuration
hmrol shell/bashrc .bashrc
hmrol shell/zshrc .zshrc
hmrol Xresources/base .Xresources

# git configuration
hmrol git/gitconfig .gitconfig
hmrol git/gitignore .gitignore

# gpg configuration
hmrol gpg/gpg.conf .gnupg/gpg.conf

# misc
hmrol etc/tmux.conf .tmux.conf
hmrol etc/gdbinit .gdbinit

# Import local configs.
[ -f $BASE/local/$CONFIG ] && . $BASE/local/$CONFIG
[ -f $BASE/priv/$CONFIG ] && . $BASE/priv/$CONFIG

: # Clear command status
