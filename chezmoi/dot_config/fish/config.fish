if not set -q TCONF
    set -gx TCONF $HOME/tconf
end

# Define the layers to load in order
set -l layers shell/fish local/shell/fish priv/shell/fish

for layer in $layers
    set -l path "$TCONF/$layer"

    # Add functions to path
    if test -d "$path/functions"
        set -p fish_function_path "$path/functions"
    end

    # Source conf.d (vars, aliases, config)
    if test -d "$path/conf.d"
        for file in $path/conf.d/*.fish
            source $file
        end
    end
end
