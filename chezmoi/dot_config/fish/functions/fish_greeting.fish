function fish_greeting -d 'Display startup greeting'
    set_color -d white
    printf "// %s\n" (date "+%A, %B %d, %Y • %T %Z")
    printf "// %s@%s (fish-shell)\n" (whoami) (hostname)
    set_color normal
end
