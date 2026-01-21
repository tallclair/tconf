# Connect agents
if not set -q SSH_CLIENT; and not set -q SSH_TTY
    if type -q keychain
        keychain --quiet --quick gh_tallclair google_compute_engine
        if test -f $HOME/.keychain/$hostname-fish
            source $HOME/.keychain/$hostname-fish
        end
    end
end
