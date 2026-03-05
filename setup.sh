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
hmrol shell/local_bashrc .bashrc
hmrol shell/zshrc .zshrc
hmrol Xresources/base .Xresources
hmrol shell/fish/config.fish .config/fish/config.fish

# git configuration
hmrol git/gitconfig .gitconfig
hmrol git/gitignore .gitignore

hml jj/config.toml .config/jj/conf.d/00-config.toml

# gpg configuration
hmrol gpg/gpg.conf .gnupg/gpg.conf

# gemini-cli
hml gemini/policy.toml .gemini/policies/policy.toml

# micro editor
hml micro/bindings.json .config/micro/bindings.json

# misc
hmrol etc/tmux.conf .tmux.conf
hmrol etc/gdbinit .gdbinit
hmrol etc/inputrc  .inputrc
hmrol etc/shpool.toml .config/shpool/config.toml

# Import local configs.
[ -f $BASE/local/$CONFIG ] && . $BASE/local/$CONFIG
[ -f $BASE/priv/$CONFIG ] && . $BASE/priv/$CONFIG

: # Clear command status
