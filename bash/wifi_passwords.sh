#!/bin/bash

# Directory containing NetworkManager connection profiles
file_location="/etc/NetworkManager/system-connections/*"

# Get the directory and name of this script
script_location=$(dirname $(realpath $0))
script_name="$script_location/WifiProfilesAndKeys.txt"
total_updates=0  # Initialize total counter for updates

# this will compare with the previous text file.
check_file(){
    local store_wifi="$1"       # WiFi SSID to check
    local store_password="$2"   # WiFi password to check

    # Ensure variables are initialized
    local value_found=false
    local count=0

    # Read each set of 3 lines from the existing file
    while IFS= read -r profile_line && IFS= read -r key_line && IFS= read -r empty_line; do
    # Extract existing WiFi profile and password
    wifi_name=$(echo "$profile_line" | grep "Profile" | cut -d ':' -f 2 | awk '{$1=$1;print}')
    wifi_password=$(echo "$key_line" | grep "Key" | cut -d ':' -f 2 | awk '{$1=$1;print}')

        if ! [[ -z $wifi_name ]]; then  
            # Check if the WiFi profile and password match
            if [[ "$store_wifi" == "$wifi_name" ]]; then 
                if [[ "$store_password" == "$wifi_password" ]]; then 
                    value_found=true
                    break
                fi
            fi 
        fi
    done < $script_name

    # If not found, append to the file
    if [[ "$value_found" != true ]]; then
        echo "Adding WiFi: $store_wifi"
        # echo -e "Profile: $store_wifi\n Key: $store_password\n" >> "$script_name"
        count=$((count + 1))
    fi

    return $count
}

# Check if the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\e[31mPlease run as root or use sudo.\e[0m"
    exit 1
fi

# Check if the output file exists
if [[ -f "$script_name" ]]; then 
    state_current=true
else
    state_current=false
    echo "Creating new file: $script_name"
fi

# Loop through all NetworkManager configuration files
for item in $file_location; do
    wifi_name=$(grep ssid= "$item")
    wifi_password=$(grep psk= "$item")

    # Process only if SSID is found
    if [[ -n "$wifi_name" ]]; then
        store_wifi="${wifi_name#ssid=}"   # Remove 'ssid=' prefix
        store_password="${wifi_password#psk=}"   # Remove 'psk=' prefix if present

        # Check if the file needs to be updated
        if [[ "$state_current" == true ]]; then
            check_file "$store_wifi" "$store_password"
            total_updates=$((total_updates + $?))  # Increment total updates based on return value
        else
            # Directly add to the file if it doesn't exist yet
            echo -e "Profile: $store_wifi\n Key: $store_password\n" >> "$script_name"
            total_updates=$((total_updates + 1))  # Increment updates since it's a new file
        fi
    fi
done

# Log if no updates were made
if [[ $total_updates -eq 0 ]]; then 
    echo "No update has been made."
else
    echo "$total_updates new profiles have been added."
fi