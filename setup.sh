#!/bin/bash

set -euo pipefail

TCONF="${TCONF:=$HOME/tconf}"

. $TCONF/lib/homemaker.sh || exit 1

BASE="$HOME/tconf"
INPUT="$BASE"
OUTPUT="$HOME"
CONFIG="setup.sh"

hm_init

# i3 configuration
hmrol i3/local_config .i3/config

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
hmrol etc/inputrc  .inputrc

# Import local configs.
[ -f $BASE/local/$CONFIG ] && . $BASE/local/$CONFIG
[ -f $BASE/priv/$CONFIG ] && . $BASE/priv/$CONFIG

: # Clear command status
