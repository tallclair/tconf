#!/bin/bash
set -eu

v4l2-ctl -d "$DEVNAME" --set-ctrl=focus_automatic_continuous=0
