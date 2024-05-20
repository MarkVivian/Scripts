#!/bin/bash

echo "what kind of file are you extracting: "
echo "1) tar.xz"
echo "2) tar.gz"
echo "3) .zip"
echo "4) install .deb file"
read -p "choose one of the following: " type_name

type_name(){
    case "$type_name" in
        "1")
            echo ".tar.xz"
            ;;
        "2")
            echo ".tar.gz"
            ;;
        "3")
            echo ".zip"
            ;;
        "4")
            echo ".deb"
            ;;
        *)
            echo "unknown "
            ;;
    esac
}

name_type=$(type_name)

# this will list all the files according to the type chossen
file_choose_helper(){
    local files=() # array in bash

    # this will loop over all the files in the current directory.
    while IFP= read -r file; do
        files+=("$file")
    done < <(ls | grep "$name_type")
    
    # Check if any files were found
    if [ ${#files[@]} -eq 0 ]; then
    echo "No files of type $name_type found."
    return 1
    fi

    # Display the list of files and prompt the user to choose
    echo "Files of type $name_type"
    for ((i = 0; i < ${#files[@]}; i++)); do
    echo "$i   ${files[i]}"
    done

    # Prompt the user to choose a file
    read -p "Enter the number of the file to select: " file_number

    # Check if the input is a valid number
    if ! [[ "$file_number" =~ ^[0-9]+$ ]] || [ "$file_number" -ge ${#files[@]} ]; then
    echo "Invalid input. Please enter a valid number."
    return 1
    fi

    filename="${files[file_number]}"
    echo "$filename"

    if [[ $type_name -eq 4 ]]; then
	    echo "dpkg -i $filename"
	    dpkg -i "$filename"
	    return 1
    else
	    read -p "do you wish to change the directory where the file will be stored: (y or n)" choice
    fi

    if [[ $choice = "y" ]]; then
	    read -p "please pass the path to the file: eg /path/to/location:    " location
    else
	    location="."
    fi

    if [[ $type_name -eq 1 ]]; then
		    echo "tar -xf $filename -C $location"
		    tar -xf "$filename" -C "$location"
	    elif [[ $type_name -eq 2 ]]; then
		    echo "tar -xzf $filename -C $location"
		    tar -xzf "$filename" -C "$location"
	    else
		    echo "unzip $filename -d $location"
		    unzip "$filename" -d "$location"
    fi
}

file_choose_helper


