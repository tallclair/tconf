#!/bin/bash

TCONF=${TCONF:=$HOME/tconf}

. $TCONF/lib/homemaker.sh || exit 1

INPUT=$HOME/tconf
OUTPUT=$HOME
CONFIG=setup.sh

hm_init

# i3 configuration
hmgl .i3/config "#" {,local/,priv/}i3/{config,win_rules,keys}

# shell configuration
hml shell/bashrc .bashrc
hml shell/zshrc .zshrc
hml Xresources/base .Xresources

# git configuration
hml git/gitconfig .gitconfig
hml git/gitignore .gitignore

# gpg configuration
hml gpg/gpg.conf .gnupg/gpg.conf

# misc
hml etc/tmux.conf .tmux.conf
hml etc/gdbinit .gdbinit

# Import local configs.
[ -f $INPUT/local/$CONFIG ] && . $INPUT/local/$CONFIG
[ -f $INPUT/priv/$CONFIG ] && . $INPUT/priv/$CONFIG

: # Clear command status
