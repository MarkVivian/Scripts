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
# difference between pulling and cloning:
# pulling is used to update an existing repository, while cloning is used to create a new copy of a repository. Pulling fetches the changes from the remote repository and merges them with the local repository
# cloning creates a new directory with the contents of the remote repository. Pulling is typically used when you have already cloned a repository and want to keep it up to date, while cloning is used when you want to create a new copy of a repository for the first time.
# EG.
# cloning from a ssh url:
# git clone ssh://username@hostname:port/path/to/repository.git
# cloning from a https url:
# git clone https://hostname/path/to/repository.git