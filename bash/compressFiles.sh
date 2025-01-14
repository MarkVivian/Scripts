#!/bin/bash

# Check if files or directories are passed as arguments
if [[ $# -gt 0 ]]; then
    # Prompt the user to choose a compression method
    echo -e "Choose a compression method:\n 0. zip\n 1. tar.xz\n 2. tar.gz"
    read -p "Choice: " userChoice

    # Get the list of files and directories to compress
    file_lists=("$@")

    # Ask the user for a custom archive name (default is "archive")
    read -p "Enter a custom archive name (leave blank for default): " archiveName
    if [ -z "$archiveName" ]; then
        archiveName="archive"
    fi

    # Compress the files and directories based on the user's choice
    case "$userChoice" in
        0)
            echo "Converting to zip"
            zip -r "${archiveName}.zip" "${file_lists[@]}"
            ;;
        1)
            echo "Converting to tar.xz"
            tar -cf "${archiveName}.tar" "${file_lists[@]}"
            xz -z "${archiveName}.tar"
            ;;
        2)
            echo "Converting to tar.gz"
            tar -czf "${archiveName}.tar.gz" "${file_lists[@]}"
            ;;
        *)
            echo "Please provide an option that is actually valid."
            ;;
    esac
else
    echo "Please pass the files or directories to archive."
fi