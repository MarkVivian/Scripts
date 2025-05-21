#!/bin/bash

deb_function(){
    local content="$1"
    echo "dpkg -i $content"
    dpkg -i "$content"
    return 1
}

zip_function(){
    local content="$1"
    local locations="$2"
    echo "unzip $content -d $locations"
    unzip "$content" -d "$locations"
}

xz_function(){
    local content="$1"
    local locations="$2"
    echo "tar -xf $content -C $locations"
    tar -xf "$content" -C "$locations"
}

gz_function(){
    local content="$1"
    local locations="$2"
    echo "tar -xzf $content -C $locations"
    tar -xzf "$content" -C "$locations"
}

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

# this will list all the files according to the type chossen
file_choose_helper(){
    name_type="$1"
    
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
	    deb_function $filename
    else
	    read -p "do you wish to change the directory where the file will be stored: (y or n)" choice
    fi

    if [[ $choice = "y" ]]; then
	    read -p "please pass the path to the file: eg /path/to/location:    " location
    else
	    location="."
    fi

    if [[ $type_name -eq 1 ]]; then
        xz_function $filename $location
    elif [[ $type_name -eq 2 ]]; then
        gz_function $filename $location
    else
        zip_function $filename $location
    fi
}

# get all the files passed to this bash file.
passed_files="$#"

# check if variable is empty 
if [[ $passed_files -gt 0 ]]; then
    echo "you have provided some files."
    
    passed_files=("$@")
    echo $passed_files
    for file in "$passed_files"; do
        echo $file
        

        # check if the variable has any actual files.
        if [ -e "$file" ]; then
            echo "this type of $(file "$file")"
            # check what type of file it is.
            file_type=$(file "$file")
            case "$file_type" in
                *"gzip"*)
                    echo "the file is of type gzip"
                    gz_function "$file" "."
                    ;;
                *"XZ"*)
                    echo "this file is of type XZ"
                    xz_function "$file" "."
                    ;;
                *"Zip"*)
                    echo "this file is of type Zip"
                    zip_function "$file" "."
                    ;;
                *"Debian"*)
                    echo "this file is of type debian"
                    deb_function "$file"
                    ;;
                *)
                    echo "not known"
                    ;;
            esac

        else 
            echo "this is not a file $file"
        fi
    done
else
    echo "no files have been provided."

    echo "what kind of file are you extracting: "
    echo "1) tar.xz"
    echo "2) tar.gz"
    echo "3) .zip"
    echo "4) install .deb file"
    read -p "choose one of the following: " type_name

    name_type=$(type_name)

    file_choose_helper $name_type
fi






