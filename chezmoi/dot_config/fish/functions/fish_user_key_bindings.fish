function fish_user_key_bindings
    # Ctrl + Backspace -> delete word backward
    bind \b backward-kill-word
    bind \ch backward-kill-word

    # Ctrl + Delete -> delete word forward
    bind \e\[3\;5\~ kill-word

    # Shift + Enter -> insert newline (if supported by terminal)
    bind \e\[13\;2u 'commandline -i \n'
    bind \eOM 'commandline -i \n'
end
