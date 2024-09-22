#!/bin/bash

# todo : it will get all the wifi and their respective passwords .
# make sure the script is run in admin / elevated priveleges.
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\e[31m Please run the script in admin. \e[0m"
    exit 1
fi 

wifi_password_file="./wifi_passwords.txt"


# create an array to store all objects.
wifi_details=()

# This will get the wifi names and passwords.
get_passwords() {
    # get the wifi connection files and replace the spaces in the file names with 1^1 since i doubt anybody's wifi would have such a name.
    mapfile -t wifi_files < <(sudo find /etc/NetworkManager/system-connections -type f -name "*.nmconnection" | sed 's/ /1^1/g') 

    # loop through the wifi names.
    for file in ${wifi_files[@]}; do
        # revert the replacement done above.
        revised_file=$(echo $file | sed 's/1^1/ /g')
        
        # get the wifi name and password.
        wifi_password=$(sudo cat "$revised_file" | grep "psk=" | cut -d "=" -f 2)
        wifi_name=$(sudo cat "$revised_file" | grep "ssid=" | cut -d "=" -f 2)        

        # check if the password value is empty and if empty ignore. 
        if ! [[ $wifi_password == "" ]]; then
            wifi_details+=($(echo "$wifi_name <<<<<>>>>> $wifi_password" | sed 's/ /1^1/g'))
        fi 

    done
}

get_passwords

read_txt_content() {
    # get the content of the $wifi_password_file and store in an array.
    mapfile -t file_content < <(cat $wifi_password_file | grep "<<<<<>>>>>" | sed 's/ /1^1/g')
    
    # will store any new passwords .
    new_values=()

    # Loop through each value in the wifi_details array
    for value in ${wifi_details[@]}; do
        # Initialize a flag to true
        state=true
        # Loop through each content in the file_content array
        for content in ${file_content[@]}; do 
            # Remove '1^1' from the value and store it in value_checker
            value_checker=$(echo $value | sed 's/1^1//g')
            # Remove '1^1' from the content and store it in content_checker
            content_checker=$(echo $content | sed 's/1^1//g')
            # If value_checker is equal to content_checker, set the state flag to false
            if [[ "$value_checker" == "$content_checker" ]]; then 
                state=false
            fi
        done

        # If the state flag is still true, it means the value is not found in the file_content array
        if $state; then
            # Add the value to the new_values array
            new_values+=($value)
            # Print a message indicating that a new content is added, replacing '1^1' with a space
            echo -e "\e[31m new content added $(echo $value | sed 's/1^1/ /g') \e[0m"
        fi

    done

    # check if new_values array is empty
    if ! [[ ${#new_values[@]} == 0 ]]; then
        # Loop through each value in the new_values array
        for valued in ${new_values[@]}; do
            # Replace '1^1' with a space and add a newline character to the end
            storage="$(echo $valued | sed 's/1^1/ /g') \n"
            # Append the storage string to the wifi_password_file
            echo -e "$storage" >> $wifi_password_file
        done
    else 
        echo -e "\e[31m no new passwords have been found \e[0m"
    fi
}

# This is a function named no_txt_file
no_txt_file(){
    # Loop through each value in the wifi_details array
    for value in ${wifi_details[@]}; do
        # Use sed to replace all occurrences of '1^1' with a space in the current value
        # and store the result in the storage variable, followed by a newline character
        storage="$(echo $value | sed 's/1^1/ /g') \n"
        # Append the storage variable to the file specified by wifi_password_file
        echo -e "$storage" >> $wifi_password_file
    done
}

# check if file exists.
if [ -a "$wifi_password_file" ]; then
    read_txt_content
else    
    no_txt_file
fi 

