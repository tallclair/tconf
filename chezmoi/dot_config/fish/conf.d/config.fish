# Configure prompt
if status is-interactive
    # Initialize Starship
    starship init fish | source

    # 7. Bold the command text
    # This affects the actual command you type (e.g., 'git', 'vim')
    set -g fish_color_command --bold

    # Optional: If you want arguments bold as well (e.g., 'commit', 'filename')
    # set -g fish_color_param --bold
end

# Detect remote connections
if not set -q REMOTE_ALIAS
    if set -q SSH_CLIENT; or set -q SSH_CONNECTION; or begin test -z "$XDG_VTNR"; and test -z "$DISPLAY"; end
        set -gx REMOTE_ALIAS (hostname)
    end
end
