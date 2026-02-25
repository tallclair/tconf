# Local setup, called from tconf/setup.sh

INPUT=$TCONF/local

hmrol etc/xsession .xsession
hml etc/user-dirs.dirs .config/user-dirs.dirs
hmrol scripts/redshift.sh bin/redshift
hml jj/config.toml .config/jj/conf.d/20-local-config.toml
