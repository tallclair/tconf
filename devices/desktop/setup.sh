# Local setup, called from tconf/setup.sh

INPUT=$TCONF/local

hmrol shell/bash_profile .bash_profile
hmrol etc/xinitrc .xinitrc
hmrol etc/yaourtrc .yaourtrc
hmrol etc/gpg-agent.conf .gnupg/gpg-agent.conf
hmrol etc/pam_environment .pam_environment
