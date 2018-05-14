#!/bin/bash

NIGHT="-O 3700 -b 0.8"
DAY="-x"
REDSHIFT=/usr/bin/redshift

case $1 in
  night)
    $REDSHIFT -O 3700 -b 0.8
    ;;
  dark-night)
    $REDSHIFT -O 3200 -b 0.6
    ;;
  day)
    $REDSHIFT -x
    ;;
  *)
    $REDSHIFT $@
    ;;
esac
