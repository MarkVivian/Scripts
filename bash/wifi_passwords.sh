#!/bin/bash


file_location="/etc/NetworkManager/system-connections/*"
script_location=$(dirname $(realpath $0))
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31mPlease run as root or use sudo.\e[0m"
else
    wifi_detail_list=()
    # loop through all the files pertaining networking.
    for item in $file_location; do
        wifi_name=$(grep ssid= "$item")
        wifi_password=$(grep psk= "$item")

        # check if the wifi string is empty
        if [[ -n $wifi_name ]]; then
            store_wifi="${wifi_name#ssid=}"
            if [[ -n $wifi_password ]]; then 
                store_password=${wifi_password#psk=}                
            fi 
        fi
        echo "$script_location"
        echo -e " wifi = $store_wifi \n password = $store_password \n" >> "$script_location/wifi_keys_passwords.txt"
    done
fi
