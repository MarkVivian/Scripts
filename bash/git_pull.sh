#!/bin/bash

# logging the script.
logfile="/var/log/script_logs/git_pull.log"
touch $logfile
chmod 755 $logfile

# Redirect stdout and stderr.
exec &> "$logfile"
echo "Script started at $(date)"


while true; do
        # check if there is internet connection
        connection=$(ping -c 1 8.8.8.8) 2>&1

        if [[ $connection ]];then 
            echo "cyber security check "
            cd ~/Documents/cyber_security/ && git pull 2>&1
            echo "scripts check "
            cd ~/Documents/Scripts/ && git pull 2>&1
            break
        else 
            echo "there is no internet connection... waiting for 10 seconds"
            sleep 10
        fi 
done
