# Shared aliases

# Utils
# Keep these as aliases because they involve pipes/redirection
alias uuid='cat /dev/urandom | tr -dc a-z0-9 | head -c 32; echo'
alias xcp='xclip -selection clipboard'

function timestamp -d 'Prepend timestamp to each line of input'
    while read -l line
        echo -e (date +"%H:%M:%S.%3N")"	 $line"
    end
end

# Filesystem
if test -f ~/.fish_aliases
    source ~/.fish_aliases
end

# Go
abbr -a gag "ag -G '.*\.go\$'"

# Common typos (maintained as abbreviations for auto-correction)
abbr -a gits 'git status'
abbr -a kubcetl 'kubectl'
abbr -a kuebctl 'kubectl'
