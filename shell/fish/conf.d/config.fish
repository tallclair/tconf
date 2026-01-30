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

function fish_greeting -d 'Display startup greeting'
    set_color -d white
    printf "// %s • Week %s • fish-shell\n" (date "+%A, %b %d") (date "+%V")
    set_color normal
end
