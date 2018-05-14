# Local setup, called from tconf/setup.sh

INPUT=$TCONF/local

hml etc/xsession .xsession
hml etc/user-dirs.dirs .config/user-dirs.dirs
hml scripts/redshift.sh bin/redshift
