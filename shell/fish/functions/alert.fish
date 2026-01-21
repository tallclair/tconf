function alert --description 'Notify when a command is done'
    set -l last_status $status
    set -l cmd $argv
    set -l title "Task Finished"
    set -l icon "terminal"

    if test $last_status -ne 0
        set icon "error"
        set title "Task Failed"
    end

    if test (count $cmd) -eq 0
        set cmd (history | head -n1)
        # Strip 'alert' from the end of the command
        set cmd (string replace -r '[
;]+alert.*$' '' -- $cmd)
    end

    if type -q notify-send
        notify-send --urgency=low -i "$icon" "$title" "$cmd"
    else if type -q osascript
        osascript -e "display notification \"$cmd\" with title \"$title\""
    end
end