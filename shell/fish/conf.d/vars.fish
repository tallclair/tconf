# Shared environment variables

if not set -q TCONF
    set -gx TCONF $HOME/tconf
end

set -gx EDITOR "zed"
set -gx GITHUB_USER tallclair
set -gx STARSHIP_CONFIG $TCONF/etc/starship.toml

# Path configuration
fish_add_path --path --prepend $HOME/bin

set -gx GOPATH $HOME/go
fish_add_path --path --prepend $GOPATH/bin

fish_add_path --path --prepend $HOME/.local/bin
fish_add_path --path --append $TCONF/git/bin

if not set -q REMOTE_ALIAS
    if set -q SSH_CLIENT; or set -q SSH_CONNECTION; or begin test -z "$XDG_VTNR"; and test -z "$DISPLAY"; end
        set -gx REMOTE_ALIAS (hostname)
    end
end
