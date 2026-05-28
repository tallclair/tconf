function timestamp -d 'Prepend timestamp to each line of input'
    while read -l line
        echo -e (date +"%H:%M:%S.%3N")"	 $line"
    end
end
