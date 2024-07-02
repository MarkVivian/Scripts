#!/bin/bash


file_location="/home/$(whoami)/.tmux.confi"

if [[ -e $file_location ]]; then 
    echo "file already exists"
else
    echo "creating file $file_location"
    words=$(cat << EOF
set -g mouse on
setw -g mode-keys vi
EOF
)
    bash -c "echo -e '$words' > $file_location"
    ## this will execute the string as a terminal command.
fi
