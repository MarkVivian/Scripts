#!/bin/bash

help_details() {
    echo "This is a program to rename multiple files."
    echo "***********FUNCTIONALITY***********"
    echo "provide the path first in the form"
    echo "  EG"
    echo "      ./path/to/directory"
    echo "then provide the extension of the files"
    echo "  EG."
    echo "      ./multi_namer.sh /path/to/directory txt"
}

filepath=$1
extension_to_add=$2

remove_unwanted_items() {
    first_character_extension="${extension_to_add:0:1}"
    last_character_path="${filepath: -1}"
    
    if [[ $first_character_extension == "." ]]; then 
        extension_to_add="${extension_to_add:1}"
    fi

    if [[ $last_character_path == "/" ]]; then 
        filepath="${filepath:0:-1}"
    fi
}

files_in_directory=()

if [[ -d $filepath ]] && [[ -n $extension_to_add ]]; then
    remove_unwanted_items
    echo "do you want all the files to be affected"
    echo "1) yes"
    echo "2) no" 
    read choice1
    files_in_directory=$(ls $filepath)
    for file in $files_in_directory; do
        if [[ $choice1 -eq 1 ]]; then
            mv "$filepath/$file" "$filepath/$file.$extension_to_add" 
        elif [[ $choice1 -eq 2 ]]; then 
            echo "I have no idea."
        fi
    done
else
    help_details
fi
